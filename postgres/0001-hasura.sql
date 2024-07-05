-- initialize hasura user
DO $$
BEGIN
  CREATE ROLE "${RUNCORE_HASURA_USER}" WITH
    PASSWORD '${RUNCORE_HASURA_PASSWORD}'
    LOGIN
    NOINHERIT
    CREATEROLE
    NOREPLICATION;

  GRANT ALL PRIVILEGES ON DATABASE "${POSTGRES_DB}" TO "${RUNCORE_HASURA_USER}";

  CREATE SCHEMA IF NOT EXISTS hdb_catalog AUTHORIZATION "${RUNCORE_HASURA_USER}";

  ALTER SCHEMA hdb_catalog OWNER TO "${RUNCORE_HASURA_USER}";

  GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO "${RUNCORE_HASURA_USER}";
  GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO "${RUNCORE_HASURA_USER}";

  GRANT USAGE ON SCHEMA public TO "${RUNCORE_HASURA_USER}";
  GRANT ALL ON ALL TABLES IN SCHEMA public TO "${RUNCORE_HASURA_USER}";
  GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "${RUNCORE_HASURA_USER}";
  GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Hasura already setup';
END $$;
