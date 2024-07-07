-- trigger schema
CREATE SCHEMA IF NOT EXISTS trigger;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA trigger
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA trigger TO "${RUNCORE_HASURA_USER}";

-- trigger.events
BEGIN;
  CALL create_pre_migration('trigger.events');

  CREATE TABLE trigger.events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    sorting SERIAL,
    name text UNIQUE NOT NULL,
    description text NOT NULL,

    is_active bool NOT NULL DEFAULT true
  );

  COMMENT ON TABLE trigger.events
  IS 'Events which can trigger webhooks';

  CALL create_post_migration('trigger.events');
COMMIT;

-- trigger.hooks
BEGIN;
  CALL create_pre_migration('trigger.hooks');

  CREATE TABLE trigger.hooks (
    id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    event_id uuid NOT NULL REFERENCES trigger.events(id),

    url text NOT NULL,
    headers jsonb NOT NULL,
    body jsonb NOT NULL
  );

  COMMENT ON TABLE trigger.hooks
  IS 'Setup Webhooks to Run';

  CALL create_post_migration('trigger.hooks');
COMMIT;

--trigger.logs
BEGIN;
  CALL create_pre_migration('trigger.logs');

  CREATE TABLE trigger.logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    hook_id uuid NOT NULL REFERENCES trigger.hooks(id),
    event_id uuid NOT NULL REFERENCES trigger.events(id),

    url text NOT NULL,
    headers jsonb NOT NULL,
    body jsonb NOT NULL,
    run_at timestamptz,

    return_code smallint,
    return_body text
  );

  COMMENT ON TABLE trigger.logs
  IS 'Instances when a Webhook was Triggered';

  CALL create_post_migration('trigger.logs');
COMMIT;
