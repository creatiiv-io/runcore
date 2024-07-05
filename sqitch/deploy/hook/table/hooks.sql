-- Deploy AppCore:hook/table/hooks to pg

BEGIN;

CREATE TABLE hook.hooks (
  id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

  account_id uuid NOT NULL REFERENCES client.accounts(id),
  event_id uuid NOT NULL REFERENCES hook.events(id),

  url text NOT NULL,
  headers jsonb NOT NULL,
  body jsonb NOT NULL
);

COMMENT ON TABLE hook.hooks
IS 'Setup Webhooks to Run';

COMMIT;
