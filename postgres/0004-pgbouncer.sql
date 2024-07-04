-- pgbouncer
DO $$
BEGIN
  CREATE USER "${RUNCORE_PGBOUNCER_USER}";

  REVOKE ALL PRIVILEGES ON SCHEMA public FROM "${RUNCORE_PGBOUNCER_USER}";

  CREATE SCHEMA pgbouncer AUTHORIZATION "${POSTGRES_USER}";

  CREATE OR REPLACE FUNCTION pgbouncer.user_lookup(in i_username text, out uname text, out phash text)
  RETURNS record AS $func$
  BEGIN
      SELECT usename, passwd FROM pg_catalog.pg_shadow
      WHERE usename = i_username INTO uname, phash;
      RETURN;
  END;
  $func$ LANGUAGE plpgsql SECURITY DEFINER;

  REVOKE ALL ON FUNCTION pgbouncer.user_lookup(text) FROM public;
  GRANT USAGE ON SCHEMA pgbouncer TO "${RUNCORE_PGBOUNCER_USER}";
  GRANT EXECUTE ON FUNCTION pgbouncer.user_lookup(text) TO "${RUNCORE_PGBOUNCER_USER}";
  GRANT postgres TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'PGBouncer already setup';
END $$;
