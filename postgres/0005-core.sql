-- setup schema
DO $$
BEGIN
  CREATE SCHEMA IF NOT EXISTS setup;

  -- necessary for hasura user to access and track objects
  ALTER DEFAULT PRIVILEGES IN SCHEMA setup
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
  GRANT USAGE ON SCHEMA setup TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Schema "setup" already setup';
END $$;

-- client schema
DO $$
BEGIN
  CREATE SCHEMA IF NOT EXISTS client;

  -- necessary for hasura user to access and track objects
  ALTER DEFAULT PRIVILEGES IN SCHEMA client
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
  GRANT USAGE ON SCHEMA client TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Schema "client" already client';
END $$;

-- offer schema
DO $$
BEGIN
  CREATE SCHEMA IF NOT EXISTS offer;

  -- necessary for hasura user to access and track objects
  ALTER DEFAULT PRIVILEGES IN SCHEMA offer
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
  GRANT USAGE ON SCHEMA offer TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Schema "offer" already offer';
END $$;

-- trigger schema
DO $$
BEGIN
  CREATE SCHEMA IF NOT EXISTS trigger;

  -- necessary for hasura user to access and track objects
  ALTER DEFAULT PRIVILEGES IN SCHEMA trigger
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
  GRANT USAGE ON SCHEMA trigger TO "${RUNCORE_HASURA_USER}";
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Schema "trigger" already trigger';
END $$;
