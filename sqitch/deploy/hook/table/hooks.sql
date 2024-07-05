-- Deploy AppCore:core/table/webhooks to pg

BEGIN;

CREATE TABLE core.webhooks (
  id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

  account_id uuid NOT NULL REFERENCES core.accounts(id),
  event_id uuid NOT NULL REFERENCES core.events(id),

  url text NOT NULL,
  headers jsonb NOT NULL,
  body jsonb NOT NULL
);

COMMENT ON TABLE core.webhooks
IS 'Setup Webhooks to Run';

COMMIT;
