-- extension pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- extension citext
CREATE EXTENSION IF NOT EXISTS citext;

-- initialize hasura user
DO $$
BEGIN
  CREATE USER "${RUNCORE_HASURA_USER}" WITH
    NOINHERIT
    NOREPLICATION;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'user "${RUNCORE_HASURA_USER}" already exists, skipping';
END $$;

-- change password for hasura user
ALTER USER "${RUNCORE_HASURA_USER}"
WITH PASSWORD '${RUNCORE_HASURA_PASSWORD}';

-- make sure we lock down the hasura user
REVOKE ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" FROM "${RUNCORE_HASURA_USER}";

-- create hdb_catalog for migrations
CREATE SCHEMA IF NOT EXISTS hdb_catalog AUTHORIZATION "${RUNCORE_HASURA_USER}";
ALTER SCHEMA hdb_catalog OWNER TO "${RUNCORE_HASURA_USER}";

-- hasura needs to interogate shemas
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO "${RUNCORE_HASURA_USER}";
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO "${RUNCORE_HASURA_USER}";

-- give access to hasura user
GRANT USAGE, CREATE ON SCHEMA public TO "${RUNCORE_HASURA_USER}";
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "${RUNCORE_HASURA_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO "${RUNCORE_HASURA_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO "${RUNCORE_HASURA_USER}";

GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "${RUNCORE_HASURA_USER}";

-- domain datatype
DO $$
BEGIN
  CREATE DOMAIN datatype AS text
    CONSTRAINT datatype CHECK (VALUE IN ('number','string','boolean'));
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "datatype" already exists, skipping';
END $$;

-- domain jsonvalue
DO $$
BEGIN
  CREATE DOMAIN jsonvalue AS jsonb
    CONSTRAINT jsonvalue_check CHECK (jsonb_typeof(VALUE) IN ('number','string','boolean'));
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "jsonvalue" already exists, skipping';
END $$;

-- function to_jsonvalue(text)
CREATE OR REPLACE FUNCTION to_jsonvalue(input text)
RETURNS jsonvalue AS $$
DECLARE
  num_pattern text := '^[0-9]+(\.[0-9]+)?$';
BEGIN
  -- Check if the input matches the numeric pattern
  IF input ~ num_pattern THEN
    RETURN (to_jsonb(input::numeric))::jsonvalue;
  -- Check if the input is 'true' or 'false'
  ELSIF input = 'true' OR input = 'false' THEN
    RETURN (to_jsonb(input::boolean))::jsonvalue;
  -- Treat it as text otherwise
  ELSE
    RETURN (to_jsonb(input))::jsonvalue;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- function value_to_jsonvalue()
CREATE OR REPLACE FUNCTION value_to_jsonvalue()
RETURNS TRIGGER AS $$
  BEGIN
    NEW.value := to_jsonvalue(NEW.value::text);
    RETURN NEW;
  END
$$ LANGUAGE plpgsql;

-- domain locale
DO $$
BEGIN
  CREATE DOMAIN locale AS char(2)
    CONSTRAINT locale_check CHECK ((VALUE ~ '^[a-z]{2}$'));
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "locale" already exists, skipping';
END $$;

-- domain domain_name
DO $$
BEGIN
  CREATE DOMAIN domain_name AS public.citext
    CONSTRAINT domain_name_check CHECK (
      VALUE ~* '^([a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])\.)+[a-z]{2,}$'
      AND LENGTH(VALUE) <= 253
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "domain_name" already exists, skipping';
END $$;

-- domain url
DO $$
BEGIN
  CREATE DOMAIN url AS public.citext
    CONSTRAINT url_check CHECK (
      VALUE ~* '^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])\.)+[a-z]{2,}(:[0-9]{0,5})?(?:\/.*)?$'
      AND LENGTH(VALUE) <= 2048
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "url" already exists, skipping';
END $$;

-- domain email
DO $$
BEGIN
  CREATE DOMAIN email AS public.citext
    CONSTRAINT email_check CHECK (
      VALUE ~* '^[a-z0-9.!#$%&''*+/=?^_`{|}~-]+@([a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])\.)+[a-z]{2,}$'
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "email" already exists, skipping';
END $$;

-- domain phone
DO $$
BEGIN
  CREATE DOMAIN phone AS public.citext
    CONSTRAINT phone_check CHECK (
      VALUE ~* '^\+[1-9][0-9]{0,2}\.[0-9]{4,14}(?:x[0-9]+)?$'
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "phone" already exists, skipping';
END $$;

-- domain password
DO $$
BEGIN
  CREATE DOMAIN password AS public.citext
    CONSTRAINT password_check CHECK (
      VALUE ~ '(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^0-9a-zA-Z]).{9,}'
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "phone" already exists, skipping';
END $$;

-- domain entity
DO $$
BEGIN
  CREATE DOMAIN entity AS public.citext
    CONSTRAINT entity_check CHECK (VALUE ~ '^[a-z][a-z0-9_-]+[a-z0-9]$');
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "entity" already exists, skipping';
END $$;

-- domain entity_scoped
DO $$
BEGIN
  CREATE DOMAIN entity_scoped AS public.citext
    CONSTRAINT entity_scoped_check CHECK (VALUE ~ '^[a-z][a-z0-9_-]+[a-z](\.[a-z][a-z0-9_-]+[a-z0-9])?$');
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "entity_scoped" already exists, skipping';
END $$;

-- domain jwt
DO $$
BEGIN
  CREATE DOMAIN jwt AS text
    CONSTRAINT jwt_check CHECK (
      VALUE ~* '^[a-z0-9_-]+\.[a-z0-9_-]+\.[a-z0-9_-]$'
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "jwt" already exists, skipping';
END $$;

-- domain shortcode
DO $$
BEGIN
  CREATE DOMAIN shortcode AS varchar(20)
    CONSTRAINT shortcode_check CHECK (
      VALUE ~* '^[a-z][a-z0-9-]+[a-z0-9]$' AND length(VALUE) <= 20
    );
EXCEPTION WHEN others THEN
  RAISE NOTICE 'domain "shortcode" already exists, skipping';
END $$;

-- procedure watch_create_table
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
    RAISE EXCEPTION 'another process is currently migrating the table %.%, please try again later.',
      target_schema, target_table;
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

-- procedure after_create_table
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
    RAISE EXCEPTION 'another process is currently migrating the table %.%, please try again later.',
      target_schema, target_table;
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
    RAISE NOTICE 'table "%.%" new, creating',
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

  -- Compare table structure by checking columns, ignoring generated columns
  FOR rec IN (
    SELECT
      temp_isc.column_name,
      temp_isc.data_type,
      temp_isc.is_nullable,
      replace(temp_isc.column_default, migrate_schema, target_schema) AS column_default,
      temp_isc.is_generated
    FROM information_schema.columns temp_isc
    WHERE temp_isc.table_schema = migrate_schema
      AND temp_isc.table_name = target_table
    EXCEPT
    SELECT
      orig_isc.column_name,
      orig_isc.data_type,
      orig_isc.is_nullable,
      orig_isc.column_default,
      orig_isc.is_generated
    FROM information_schema.columns orig_isc
    WHERE orig_isc.table_schema = target_schema
      AND orig_isc.table_name = target_table
  ) LOOP
    -- RAISE NOTICE 'Column difference: % is not identical',
    --   rec;

    identical := false;
    EXIT;
  END LOOP;

  -- Compare indexes to check for changes, ignoring names but focusing on structural differences
  FOR rec IN (
    SELECT
      indisunique,
      indkey::text,
      pg_get_expr(indpred, indrelid) AS index_predicate,
      replace(pg_get_indexdef(indexrelid), migrate_schema, target_schema) AS index_definition
    FROM pg_index
    WHERE indrelid = (quote_ident(migrate_schema) || '.' || quote_ident(target_table))::regclass
    EXCEPT
    SELECT
      indisunique,
      indkey::text,
      pg_get_expr(indpred, indrelid) AS index_predicate,
      pg_get_indexdef(indexrelid) AS index_definition
    FROM pg_index
    WHERE indrelid = (quote_ident(target_schema) || '.' || quote_ident(target_table))::regclass
  ) LOOP
    -- RAISE NOTICE 'Column difference: % is not identical',
    --   rec;

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

    -- Report and return
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

  -- Determine intersecting columns, excluding generated columns
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
      AND temp_isc.is_generated = 'NEVER'
    INTERSECT
    SELECT
      orig_isc.column_name
    FROM information_schema.columns orig_isc
    WHERE orig_isc.table_schema = target_schema
      AND orig_isc.table_name = target_table
      AND orig_isc.is_generated = 'NEVER'
  ) isc;

  -- Check if column names are empty and raise an exception if true
  IF column_names IS NULL THEN
    RAISE EXCEPTION 'table %.% fields changed. migration error',
      target_schema, target_table;
  END IF;

  -- Transfer data from the old table to the new table, using OVERRIDING SYSTEM VALUE for identity columns
  EXECUTE format(
    'INSERT INTO %I.%I (%s) OVERRIDING SYSTEM VALUE SELECT %s FROM %I.%I',
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
      'ALTER TABLE %I.%I ENABLE TRIGGER ALL',
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

-- revoke permissions for everyone
REVOKE ALL ON PROCEDURE watch_create_table(text) FROM public;
REVOKE ALL ON PROCEDURE after_create_table(text) FROM public;

-- function table_insert_order
CREATE OR REPLACE FUNCTION table_insert_order()
RETURNS TABLE(tablename text)
AS $$
BEGIN
  -- Create temp storage for our list
  CREATE TEMP TABLE temp_table_insert_order (
    tablename text PRIMARY KEY
  );

  -- Insert independent tables (no foreign key dependencies)
  INSERT INTO temp_table_insert_order (tablename)
  SELECT pt.schemaname || '.' || pt.tablename
  FROM pg_tables pt
  WHERE pt.schemaname NOT IN ('pg_catalog', 'information_schema')
    AND pt.tablename != 'temp_table_insert_order'
    AND pt.schemaname || '.' || pt.tablename NOT IN (
      SELECT DISTINCT pc.conrelid::regclass::text
      FROM pg_constraint pc
      WHERE pc.contype = 'f'
    );

  -- Start process loop
  LOOP
    -- Insert tables where all foreign key dependencies are in temp table
    INSERT INTO temp_table_insert_order (tablename)
    SELECT pt.schemaname || '.' || pt.tablename
    FROM pg_tables pt
    WHERE pt.schemaname NOT IN ('pg_catalog', 'information_schema')
      AND pt.tablename != 'temp_table_insert_order'
      AND pt.schemaname || '.' || pt.tablename NOT IN (
        SELECT tt.tablename
        FROM temp_table_insert_order tt
      )
      AND NOT EXISTS (
        SELECT 1
        FROM pg_constraint pc
        WHERE pc.conrelid = (pt.schemaname || '.' || pt.tablename)::regclass
          AND pc.conrelid != pc.confrelid
          AND pc.contype = 'f'
          AND pc.confrelid::regclass::text NOT IN (
            SELECT tt.tablename
            FROM temp_table_insert_order tt
          )
      )
    ON CONFLICT DO NOTHING;

    -- Exit loop if no new rows were added
    IF NOT FOUND THEN
      EXIT;
    END IF;
  END LOOP;

  -- Return the result
  RETURN QUERY
  SELECT tt.tablename
  FROM temp_table_insert_order tt;

  -- Clean up the temporary table
  DROP TABLE IF EXISTS temp_table_insert_order;
END;
$$ LANGUAGE plpgsql;

-- revoke permissions for everyone
REVOKE ALL ON FUNCTION table_insert_order() FROM public;

-- initialize pgbouncer user
DO $$
BEGIN
  CREATE USER "${RUNCORE_PGBOUNCER_USER}" WITH
    NOINHERIT
    NOREPLICATION;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'user "${RUNCORE_PGBOUNCER_USER}" already exists';
END $$;

-- change password for pgbouncer user
ALTER USER "${RUNCORE_PGBOUNCER_USER}"
WITH PASSWORD '${RUNCORE_PGBOUNCER_PASSWORD}';

-- we don't need much here
REVOKE ALL PRIVILEGES ON SCHEMA public FROM "${RUNCORE_PGBOUNCER_USER}";

-- it needs it own schema the following function
CREATE SCHEMA IF NOT EXISTS pgbouncer AUTHORIZATION "${POSTGRES_USER}";

-- we only need this function to lookup a user for pg bouncer
CREATE OR REPLACE FUNCTION pgbouncer.user_lookup(
  in i_username text,
  out uname text,
  out phash text
) RETURNS record AS $$
BEGIN
    SELECT usename, passwd FROM pg_catalog.pg_shadow
    WHERE usename = i_username INTO uname, phash;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- nobody else should be using this function
REVOKE ALL ON FUNCTION pgbouncer.user_lookup(text) FROM public;
GRANT USAGE ON SCHEMA pgbouncer TO "${RUNCORE_PGBOUNCER_USER}";
GRANT EXECUTE ON FUNCTION pgbouncer.user_lookup(text) TO "${RUNCORE_PGBOUNCER_USER}";

-- function sharecode
CREATE OR REPLACE FUNCTION sharecode(value int)
RETURNS text AS $$
DECLARE
  -- Declare variables for pseudo encryption
  l1 int;
  l2 int;
  r1 int;
  r2 int;
  i int := 0;
  encrypted_value int;
  -- Declare variables for base-n conversion
  alphabet text := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  base int := length(alphabet);
  _n int;
  output text := '';
  pad_length int;
  desired_length int := 6;
BEGIN
  -- Step 1: Perform pseudo encryption
  l1 := (value >> 16) & 65535;
  r1 := value & 65535;
  WHILE i < 3 LOOP
    l2 := r1;
    r2 := l1 # ((((1366 * r1 + 150889) % 714025) / 714025.0) * 32767)::int;
    l1 := l2;
    r1 := r2;
    i := i + 1;
  END LOOP;

  encrypted_value := (r1 << 16) + l1;
  _n := abs(encrypted_value);

  -- Step 2: Convert encrypted value to the custom base
  LOOP
    output := output || substr(alphabet, 1 + (_n % base)::int, 1);
    _n := _n / base;
    EXIT WHEN _n = 0;
  END LOOP;

  -- Step 3: Pad the output if necessary to ensure it has exactly 6 characters
  pad_length := desired_length - length(output);
  IF pad_length > 0 THEN
    output := repeat(substr(alphabet, 1, 1), pad_length) || output;
  END IF;

  -- Edge case: If the output somehow is more than 6 characters, truncate it
  IF length(output) > desired_length THEN
    output := substr(output, 1, desired_length);
  END IF;

  RETURN output;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
