-- initialize auth user
DO $$
BEGIN
  CREATE ROLE "${RUNCORE_AUTH_USER}" WITH
    PASSWORD '${RUNCORE_AUTH_PASSWORD}'
    LOGIN
    NOINHERIT
    CREATEROLE
    NOREPLICATION;

  ALTER ROLE "${RUNCORE_AUTH_USER}" SET search_path TO auth;

  CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION "${RUNCORE_AUTH_USER}";

  SET ROLE "${RUNCORE_AUTH_USER}";

  -- necessary for hasura user to access and track objects
  ALTER DEFAULT PRIVILEGES IN SCHEMA auth
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
  GRANT USAGE ON SCHEMA auth TO "${RUNCORE_HASURA_USER}";

  RESET ROLE;

  -- this is needed in case of events
  -- reference: https://hasura.io/docs/latest/deployment/postgres-requirements/
  GRANT USAGE ON SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
  GRANT CREATE ON SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
  GRANT ALL ON ALL TABLES IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
  GRANT ALL ON ALL SEQUENCES IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
  GRANT ALL ON ALL FUNCTIONS IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";

  -- restore search_path so citext and other extensions are available
  ALTER ROLE "${RUNCORE_AUTH_USER}" SET search_path TO public;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Auth already setup';
END $$;
