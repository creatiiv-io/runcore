CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE OR REPLACE PROCEDURE watch_create_table(
  target_table text
) AS $$
DECLARE
  target_schema text DEFAULT 'public';
  migrate_schema text;
  rec RECORD;
  lock_key bigint;
BEGIN
  -- Extract schema and adjust target_table
  IF position('.' IN target_table) > 0 THEN
    target_schema := split_part(target_table, '.', 1);
    target_table := split_part(target_table, '.', 2);
  END IF;

  -- Generate a unique lock key from the schema and table name
  SELECT hashtext(target_schema || '.' || target_table)::int8 INTO lock_key;

  -- Attempt to acquire the advisory lock without blocking
  IF NOT pg_try_advisory_xact_lock(lock_key) THEN
    RAISE EXCEPTION 'another process is currently migrating the table %.%, please try again later.', target_schema, target_table;
  END IF;

  -- Create the new (migration) schema
  migrate_schema := target_schema || '_' || target_table || '_' || to_hex(abs(lock_key));

  -- RAISE NOTICE 'creating schema "%"',
  --   migrate_schema;

  EXECUTE format(
    'CREATE SCHEMA IF NOT EXISTS %I',
    migrate_schema
  );

  -- Check if the table exists and return early if it doesn't
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.tables ist
    WHERE ist.table_schema = target_schema
      AND ist.table_name = target_table
  ) THEN
    -- RAISE NOTICE 'new table %.%',
    --   target_schema, target_table;

    RETURN;
  END IF;

  -- Disable foreign key constraints pointing to the table
  FOR rec IN (
    SELECT
      pcl.relnamespace::regnamespace AS schema_name,
      pcl.relname AS table_name
    FROM pg_constraint pgc
    JOIN pg_class pcl ON (pcl.oid = pgc.conrelid)
    WHERE pgc.confrelid = (target_schema || '.' || target_table)::regclass
      AND pgc.contype = 'f'
  ) LOOP
    -- RAISE NOTICE 'disable triggers for table %.%',
    --   rec.schema_name, rec.table_name;

    EXECUTE format(
      'ALTER TABLE %I.%I DISABLE TRIGGER ALL',
      rec.schema_name, rec.table_name
    );
  END LOOP;

  -- Disable indexes
  UPDATE pg_index
  SET indisvalid = false
  WHERE indrelid = (target_schema || '.' || target_table)::regclass;

  -- RAISE NOTICE 'moving table %.% to schema %',
  --   target_schema, target_table, migrate_schema;

  -- Move the table to the new (migration) schema
  EXECUTE format(
    'ALTER TABLE %I.%I SET SCHEMA %I',
    target_schema, target_table, migrate_schema
  );
END $$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE after_create_table(
  target_table text
) AS $$
DECLARE
  target_schema text DEFAULT 'public';
  migrate_schema text;
  rec RECORD;
  column_names text;
  identical boolean := true;
  lock_key bigint;
BEGIN
  -- Extract schema and adjust target_table
  IF position('.' IN target_table) > 0 THEN
    target_schema := split_part(target_table, '.', 1);
    target_table := split_part(target_table, '.', 2);
  END IF;

  -- Generate a unique lock key from the schema and table name
  SELECT
    hashtext(target_schema || '.' || target_table)::int8
  INTO
    lock_key;

  -- Ensure we still hold the lock
  IF NOT pg_try_advisory_xact_lock(lock_key) THEN
    RAISE EXCEPTION 'another process is currently migrating the table %.%, please try again later.', target_schema, target_table;
  END IF;

  -- Determine new (migration) schema
  migrate_schema := target_schema || '_' || target_table || '_' || to_hex(abs(lock_key));

  -- Check if the table exists in the migration schema
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.tables ist
    WHERE ist.table_schema = migrate_schema
      AND ist.table_name = target_table
  ) THEN
    -- RAISE NOTICE 'table "%.%" new, creating',
    --   target_schema, target_table;

    -- RAISE NOTICE 'droping schema "%"',
    --   migrate_schema;

    -- Drop the migration schema
    EXECUTE format(
      'DROP SCHEMA IF EXISTS %I CASCADE',
      migrate_schema
    );

    RETURN;
  END IF;

  -- Compare table structure by checking columns
  FOR rec IN (
    SELECT
      temp_isc.column_name,
      temp_isc.data_type,
      temp_isc.is_nullable,
      replace(temp_isc.column_default, migrate_schema, target_schema) AS column_default
    FROM information_schema.columns temp_isc
    WHERE temp_isc.table_schema = migrate_schema
      AND temp_isc.table_name = target_table
    EXCEPT
    SELECT
      orig_isc.column_name,
      orig_isc.data_type,
      orig_isc.is_nullable,
      orig_isc.column_default
    FROM information_schema.columns orig_isc
    WHERE orig_isc.table_schema = target_schema
      AND orig_isc.table_name = target_table
  ) LOOP
    identical := false;
    EXIT;
  END LOOP;

  -- Ensure the new table is empty
  IF identical THEN
    EXECUTE format(
      'SELECT COUNT(*) = 0 FROM %I.%I',
      target_schema, target_table
    ) INTO identical;
  END IF;

  -- If identical
  IF identical THEN
    -- RAISE NOTICE 'identical table';

    -- Drop the new table
    EXECUTE format(
      'DROP TABLE IF EXISTS %I.%I',
      target_schema, target_table
    );

    -- RAISE NOTICE 'moving table %.% to schema %',
    --   migrate_schema, target_table, target_schema;

    -- Move the table back to the original schema
    EXECUTE format(
      'ALTER TABLE %I.%I SET SCHEMA %I',
      migrate_schema, target_table, target_schema
    );

    -- Re-enable previously disabled indexes on the new table
    UPDATE pg_index
    SET indisvalid = true
    WHERE indrelid = (target_schema || '.' || target_table)::regclass;

    -- Re-enable foreign key constraints pointing to the new table
    FOR rec IN (
      SELECT
        pcl.relnamespace::regnamespace AS schema_name,
        pcl.relname AS table_name
      FROM pg_constraint pgc
      JOIN pg_class pcl ON (pcl.oid = pgc.conrelid)
      WHERE pgc.confrelid = (target_schema || '.' || target_table)::regclass
        AND pgc.contype = 'f'
    ) LOOP
      -- RAISE NOTICE 'enable trigger for table %.%',
      --   rec.schema_name, rec.table_name;

      EXECUTE format(
        'ALTER TABLE %I.%I ENABLE TRIGGER ALL',
        rec.schema_name, rec.table_name
      );
    END LOOP;

    -- report and return
    RAISE NOTICE 'table "%.%" unchanged, skipping',
      target_schema, target_table;

    -- RAISE NOTICE 'droping schema "%"',
    --   migrate_schema;

    -- Drop the migration schema
    EXECUTE format(
      'DROP SCHEMA IF EXISTS %I CASCADE',
      migrate_schema
    );

    RETURN;
  END IF;

  -- Disable indexes on the new table before data migration
  UPDATE pg_index
  SET indisvalid = false
  WHERE indrelid = (migrate_schema || '.' || target_table)::regclass;

  -- Log data migration
  RAISE NOTICE 'table "%.%" updated, migrating data',
    target_schema, target_table;

  -- Determine the intersecting columns
  SELECT
    string_agg(isc.column_name, ', ')
  INTO
    column_names
  FROM (
    SELECT
      temp_isc.column_name
    FROM information_schema.columns temp_isc
    WHERE temp_isc.table_schema = migrate_schema
      AND temp_isc.table_name = target_table
    INTERSECT
    SELECT
      orig_isc.column_name
    FROM information_schema.columns orig_isc
    WHERE orig_isc.table_schema = target_schema
      AND orig_isc.table_name = target_table
  ) isc;

    -- Check if column names are empty and raise an exception if true
  IF column_names IS NULL THEN
    RAISE EXCEPTION 'table %.% fields changed. migration aborted.',
      target_schema, target_table;
  END IF;

  -- Transfer data from the old table to the new table
  EXECUTE format(
    'INSERT INTO %I.%I (%s) SELECT %s FROM %I.%I',
    target_schema, target_table, column_names, column_names, migrate_schema, target_table
  );

  -- Re-enable foreign key constraints pointing to the new table
  FOR rec IN (
    SELECT
      pcl.relnamespace::regnamespace AS schema_name,
      pcl.relname AS table_name
    FROM pg_constraint pgc
    JOIN pg_class pcl ON (pcl.oid = pgc.conrelid)
    WHERE pgc.confrelid = (target_schema || '.' || target_table)::regclass
      AND pgc.contype = 'f'
  ) LOOP
    -- RAISE NOTICE 'enable trigger for table %.%',
    --   rec.schema_name, rec.table_name;

    EXECUTE format(
      'ALTER TABLE %I ENABLE TRIGGER ALL',
      rec.schema_name, rec.table_name
    );
  END LOOP;

  -- Recreate foreign key constraints from migrate_schema to target_schema
  FOR rec IN (
    SELECT
        pgc.conname AS constraint_name,
        pg_get_constraintdef(pgc.oid) AS constraint_definition,
        pcl.relnamespace::regnamespace AS schema_name,
        pcl.relname AS table_name
      FROM pg_constraint pgc
      JOIN pg_class pcl ON (pcl.oid = pgc.conrelid)
      WHERE pgc.confrelid = (migrate_schema || '.' || target_table)::regclass
        AND pgc.contype = 'f'
  ) LOOP
    -- RAISE NOTICE 'table %.% rewrite constraint %',
    --   rec.schema_name, rec.table_name, rec.constraint_name;

    EXECUTE format(
      'ALTER TABLE %I.%I DROP CONSTRAINT %I',
      rec.schema_name, rec.table_name, rec.constraint_name
    );
  
    EXECUTE format(
      'ALTER TABLE %I.%I ADD CONSTRAINT %I %s',
      rec.schema_name, rec.table_name, rec.constraint_name, replace(
        rec.constraint_definition,
        migrate_schema,
        target_schema
      )
    );
  END LOOP;

  -- Re-enable previously disabled indexes on the new table
  UPDATE pg_index
  SET indisvalid = true
  WHERE indrelid = (target_schema || '.' || target_table)::regclass;

  -- RAISE NOTICE 'droping schema "%"',
  --   migrate_schema;

  -- Drop the migration table
  EXECUTE format(
    'DROP TABLE IF EXISTS %I.%I CASCADE',
    migrate_schema, target_table
  );

  -- Drop the migration schema
  EXECUTE format(
    'DROP SCHEMA IF EXISTS %I CASCADE',
    migrate_schema
  );
END $$ LANGUAGE plpgsql;

REVOKE EXECUTE ON FUNCTION watch_create_table(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION after_create_table(text) FROM PUBLIC;
