-- Deploy AppCore:core/table/runlogs to pg

BEGIN;

CREATE TABLE core.runlogs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id uuid NOT NULL REFERENCES core.accounts(id),
  webhook_id uuid NOT NULL REFERENCES core.webhooks(id),
  event_id uuid NOT NULL REFERENCES core.events(id),

  url text NOT NULL,
  headers jsonb NOT NULL,
  body jsonb NOT NULL,
  run_at timestamptz,

  return_code smallint,
  return_body text
);

COMMENT ON TABLE core.runlogs
IS 'Instances when a Webhook was Triggered';

COMMIT;
