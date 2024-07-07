CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE OR REPLACE PROCEDURE create_pre_migration(
  table_name text
) AS $$
DECLARE
  schema_name text;
  new_table_name text;
  old_table_name text;
  lock_key bigint;
BEGIN
  -- Extract schema and table name
  IF position('.' IN table_name) > 0 THEN
    schema_name := split_part(table_name, '.', 1);
    new_table_name := split_part(table_name, '.', 2);
  ELSE
    schema_name := 'public';
    new_table_name := table_name;
  END IF;

  -- Generate a unique lock key from the schema and table name
  SELECT hashtext(schema_name || '.' || new_table_name)::int8 INTO lock_key;

  -- Attempt to acquire the advisory lock without blocking
  IF NOT pg_try_advisory_xact_lock(lock_key) THEN
    RAISE EXCEPTION 'Another process is currently migrating the table %s.%s, please try again later.', schema_name, new_table_name;
  END IF;

  -- Determine the dynamic old table name
  old_table_name := new_table_name || '_old_temp';

  -- Rename the old table to the old table name if it exists
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = schema_name AND table_name = new_table_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME TO %I.%I', schema_name, new_table_name, schema_name, old_table_name);
  END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_post_migration(
  table_name text
) AS $$
DECLARE
  schema_name text;
  new_table_name text;
  old_table_name text;
  rec RECORD;
  column_names text;
  identical boolean := true;
  lock_key bigint;
BEGIN
  -- Extract schema and table name
  IF position('.' IN table_name) > 0 THEN
    schema_name := split_part(table_name, '.', 1);
    new_table_name := split_part(table_name, '.', 2);
  ELSE
    schema_name := 'public';
    new_table_name := table_name;
  END IF;

  -- Determine table names
  old_table_name := new_table_name || '_old_temp';

  -- Generate a unique lock key from the schema and table name
  SELECT hashtext(schema_name || '.' || new_table_name)::int8 INTO lock_key;

  -- Ensure we still hold the lock
  PERFORM pg_advisory_xact_lock(lock_key);

  -- Check if the old table exists before proceeding
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = schema_name AND table_name = old_table_name) THEN
    RETURN;
  END IF;

  -- Check if the new table exists before proceeding
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = schema_name AND table_name = new_table_name) THEN
    RAISE NOTICE 'Table %s.%s does not exist.', schema_name, new_table_name;
    RETURN;
  END IF;

  -- Compare table structure by checking columns
  FOR rec IN (
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_schema = schema_name AND table_name = old_table_name
    EXCEPT
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_schema = schema_name AND table_name = new_table_name
  ) LOOP
    identical := false;
    EXIT;
  END LOOP;

  -- If the new table is empty and structures are identical, rename the old table back
  IF identical THEN
    EXECUTE format('SELECT COUNT(*) = 0 FROM %I.%I', schema_name, new_table_name) INTO identical;
  END IF;

  IF identical THEN
    EXECUTE format('DROP TABLE %I.%I', schema_name, new_table_name);
    EXECUTE format('ALTER TABLE %I.%I RENAME TO %I.%I', schema_name, old_table_name, schema_name, new_table_name);
    RAISE NOTICE 'Migration was unnecessary. Tables were identical.';
    RETURN;
  END IF;

  -- Log data migration
  RAISE NOTICE 'Restoring data for table %s.%s.', schema_name, new_table_name;

  -- Determine the intersecting columns
  SELECT string_agg(column_name, ', ') INTO column_names
  FROM (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = schema_name AND table_name = old_table_name
    INTERSECT
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = schema_name AND table_name = new_table_name
  ) AS intersect_cols;

  -- Transfer data from the old table to the new table
  EXECUTE format(
    'INSERT INTO %I.%I (%s) SELECT %s FROM %I.%I',
    schema_name, new_table_name, column_names, column_names, schema_name, old_table_name
  );

  -- Handle indexes
  FOR rec IN (
    SELECT indexname, indexdef
    FROM pg_indexes
    WHERE schemaname = schema_name AND tablename = old_table_name
  ) LOOP
    EXECUTE REPLACE(rec.indexdef, old_table_name, new_table_name);
    RAISE NOTICE 'Recreated index % on %.', rec.indexname, new_table_name;
  END LOOP;

  -- Handle triggers
  FOR rec IN (
    SELECT tgname, pg_get_triggerdef(oid) AS tgdef
    FROM pg_trigger
    WHERE tgrelid = format('%I.%I', schema_name, old_table_name)::regclass AND NOT tgisinternal
  ) LOOP
    EXECUTE REPLACE(rec.tgdef, old_table_name, new_table_name);
    RAISE NOTICE 'Recreated trigger % on %.', rec.tgname, new_table_name;
  END LOOP;

  -- Drop the old table
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = schema_name AND table_name = old_table_name) THEN
    EXECUTE format('DROP TABLE %I.%I', schema_name, old_table_name);
  END IF;
END $$ LANGUAGE plpgsql;

