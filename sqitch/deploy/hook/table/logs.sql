-- Deploy AppCore:hook/table/logs to pg

BEGIN;

CREATE TABLE hook.logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id uuid NOT NULL REFERENCES client.accounts(id),
  webhook_id uuid NOT NULL REFERENCES hook.hooks(id),
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

COMMIT;
