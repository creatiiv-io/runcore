-- Deploy AppCore:trigger/table/logs to pg

BEGIN;

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

COMMIT;
