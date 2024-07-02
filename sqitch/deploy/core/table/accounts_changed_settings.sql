-- Deploy AppCore:core/table/accounts_changed_settings to pg

BEGIN;

CREATE TABLE core.accounts_changed_settings (
  account_id uuid NOT NULL REFERENCES core.accounts(id),
  setting_id uuid NOT NULL REFERENCES core.settings(id),

  value jsonb NOT NULL,

  UNIQUE (account_id, setting_id)
);

COMMENT ON TABLE core.accounts_changed_settings
IS 'Domains that can be routed';

COMMIT;
