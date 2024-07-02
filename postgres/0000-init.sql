-- public
-- pgcrypt & citext is required to be installed in the
-- `public` schema because of Hasura
-- https://github.com/hasura/graphql-engine/issues/3657

-- CREATE SCHEMA IF NOT EXISTS extensions;
-- GRANT usage ON SCHEMA extensions TO appcore_auth, appcore_storage;

CREATE EXTENSION IF NOT EXISTS pgcrypto; -- WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS citext; --WITH SCHEMA extensions;

-- appcore admin role
DO $$
BEGIN
    CREATE USER appcore_admin;

  -- equivalent to the postgres role
  ALTER USER appcore_admin WITH superuser createdb createrole replication bypassrls;
EXCEPTION WHEN others THEN
    RAISE NOTICE 'AppCore admin exists';
END $$;

-- appcore hasura
DO $$
BEGIN
  CREATE USER appcore_hasura;

  GRANT postgres TO appcore_hasura;
  
  GRANT ALL PRIVILEGES ON DATABASE local TO appcore_hasura;
  
  CREATE SCHEMA IF NOT EXISTS hdb_catalog;

  ALTER SCHEMA hdb_catalog OWNER TO appcore_hasura;
  GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO appcore_hasura;
  GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO appcore_hasura;

  GRANT USAGE ON SCHEMA public TO appcore_hasura;
  GRANT ALL ON ALL TABLES IN SCHEMA public TO appcore_hasura;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO appcore_hasura;
  GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO appcore_hasura;
EXCEPTION WHEN others THEN
    RAISE NOTICE 'Hasura exists';
END $$;

-- auth schema
DO $$
BEGIN
  CREATE USER appcore_auth LOGIN NOINHERIT CREATEROLE NOREPLICATION;

  ALTER ROLE appcore_auth SET search_path TO auth;
  
  CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION appcore_admin;
  GRANT ALL PRIVILEGES ON SCHEMA auth TO appcore_auth;

  -- this is needed in case of events
  -- reference: https://hasura.io/docs/latest/deployment/postgres-requirements/
  GRANT USAGE ON SCHEMA hdb_catalog TO appcore_auth;
  GRANT CREATE ON SCHEMA hdb_catalog TO appcore_auth;
  GRANT ALL ON ALL TABLES IN SCHEMA hdb_catalog TO appcore_auth;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA hdb_catalog TO appcore_auth;
  GRANT ALL ON ALL FUNCTIONS IN SCHEMA hdb_catalog TO appcore_auth;

  -- restore search_path so citext and other extensions are available
  ALTER ROLE appcore_auth SET search_path TO public;
EXCEPTION WHEN others THEN
    RAISE NOTICE 'AppCore auth setup';
END $$;

-- storage schema
DO $$
BEGIN
  CREATE USER appcore_storage LOGIN NOINHERIT CREATEROLE NOREPLICATION;

  ALTER ROLE appcore_storage SET search_path TO storage;

  CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION appcore_admin;
  GRANT ALL PRIVILEGES ON SCHEMA storage TO appcore_storage;

  -- necessary for appcore_hasura to access and track objects created by appcore_auth and appcore_storage in the future
  ALTER DEFAULT PRIVILEGES FOR USER appcore_auth IN SCHEMA auth GRANT ALL ON TABLES TO appcore_hasura;
  ALTER DEFAULT PRIVILEGES FOR USER appcore_storage IN SCHEMA storage GRANT ALL ON TABLES TO appcore_hasura;
  GRANT USAGE ON SCHEMA auth TO appcore_hasura;
  GRANT USAGE ON SCHEMA storage TO appcore_hasura;

  -- this is needed in case of events
  -- reference: https://hasura.io/docs/latest/deployment/postgres-requirements/
  GRANT USAGE ON SCHEMA hdb_catalog TO appcore_storage;
  GRANT CREATE ON SCHEMA hdb_catalog TO appcore_storage;
  GRANT ALL ON ALL TABLES IN SCHEMA hdb_catalog TO appcore_storage;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA hdb_catalog TO appcore_storage;
  GRANT ALL ON ALL FUNCTIONS IN SCHEMA hdb_catalog TO appcore_storage;

  -- restore search_path so citext and other extensions are available
  ALTER ROLE appcore_storage SET search_path TO public;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'AppCore storage setup';
END $$;

-- pgbouncer
DO $$
BEGIN
  CREATE USER pgbouncer;

  REVOKE ALL PRIVILEGES ON SCHEMA public FROM pgbouncer;

  CREATE SCHEMA pgbouncer AUTHORIZATION appcore_admin;

  CREATE OR REPLACE FUNCTION pgbouncer.user_lookup(in i_username text, out uname text, out phash text)
  RETURNS record AS $func$
  BEGIN
      SELECT usename, passwd FROM pg_catalog.pg_shadow
      WHERE usename = i_username INTO uname, phash;
      RETURN;
  END;
  $func$ LANGUAGE plpgsql SECURITY DEFINER;

  REVOKE ALL ON FUNCTION pgbouncer.user_lookup(text) FROM public;
  GRANT USAGE ON SCHEMA pgbouncer TO pgbouncer;
  GRANT EXECUTE ON FUNCTION pgbouncer.user_lookup(text) TO pgbouncer;
  GRANT postgres TO appcore_hasura;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'PGBouncer setup';
END $$;

