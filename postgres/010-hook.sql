-- schema hook
CREATE SCHEMA IF NOT EXISTS hook;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA hook
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA hook TO "${RUNCORE_HASURA_USER}";

-- table hook.events
BEGIN;
  CALL watch_create_table('hook.events');

  CREATE TABLE hook.events (
    entity text NOT NULL,
    event text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,

    is_active bool NOT NULL DEFAULT true,
  );

  COMMENT ON TABLE hook.events
  IS 'Events which can hook webhooks';

  CALL after_create_table('hook.events');
COMMIT;

-- table hook.triggers
BEGIN;
  CALL watch_create_table('hook.triggers');

  CREATE TABLE hook.triggers (
    id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    event_id uuid NOT NULL REFERENCES hook.events(id),

    url text NOT NULL,
    headers jsonb NOT NULL,
    body jsonb NOT NULL
  );

  COMMENT ON TABLE hook.triggers
  IS 'Setup Webhooks to Run';

  CALL after_create_table('hook.triggers');
COMMIT;

--table hook.logs
BEGIN;
  CALL watch_create_table('hook.logs');

  CREATE TABLE hook.logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    hook_id uuid NOT NULL REFERENCES hook.hooks(id),
    event_id uuid NOT NULL REFERENCES hook.events(id),

    url text NOT NULL,
    headers jsonb NOT NULL,
    body jsonb NOT NULL,
    run_at timestamptz,

    return_code smallint,
    return_body text
  );

  COMMENT ON TABLE hook.logs
  IS 'Instances when a Webhook was Triggered';

  CALL after_create_table('hook.logs');
COMMIT;
