-- core schema
DO $$
BEGIN
  CREATE ROLE "${RUNCORE_STORAGE_USER}" WITH
    PASSWORD '${RUNCORE_STORAGE_PASSWORD}'
    LOGIN
    NOINHERIT
    CREATEROLE
    NOREPLICATION;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Role "${RUNCORE_STORAGE_USER}" already exists';
END $$;

ALTER ROLE "${RUNCORE_STORAGE_USER}" SET search_path TO storage;

CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION "${RUNCORE_STORAGE_USER}";

SET ROLE "${RUNCORE_STORAGE_USER}";

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA storage
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA storage TO "${RUNCORE_HASURA_USER}";

RESET ROLE;

-- this is needed in case of events
-- reference: https://hasura.io/docs/latest/deployment/postgres-requirements/
GRANT USAGE ON SCHEMA hdb_catalog TO "${RUNCORE_STORAGE_USER}";
GRANT CREATE ON SCHEMA hdb_catalog TO "${RUNCORE_STORAGE_USER}";
GRANT ALL ON ALL TABLES IN SCHEMA hdb_catalog TO "${RUNCORE_STORAGE_USER}";
GRANT ALL ON ALL SEQUENCES IN SCHEMA hdb_catalog TO "${RUNCORE_STORAGE_USER}";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA hdb_catalog TO "${RUNCORE_STORAGE_USER}";

-- restore search_path so citext and other extensions are available
ALTER ROLE "${RUNCORE_STORAGE_USER}" SET search_path TO public;
