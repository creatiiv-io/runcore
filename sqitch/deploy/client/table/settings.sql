-- Deploy AppCore:client/table/settings to pg

BEGIN;

CREATE TABLE client.settings (
  account_id uuid NOT NULL REFERENCES client.accounts(id),
  setting_id uuid NOT NULL REFERENCES setup.settings(id),

  value jsonb NOT NULL,

  UNIQUE (account_id, setting_id)
);

COMMENT ON TABLE client.settings
IS 'Domains that can be routed';

COMMIT;
