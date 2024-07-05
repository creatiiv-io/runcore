-- Deploy AppCore:client/table/configs to pg

BEGIN;

CREATE TABLE client.configs (
  account_id uuid NOT NULL REFERENCES client.accounts(id),
  form_id uuid NOT NULL REFERENCES core.forms(id),

  data jsonb NOT NULL,

  UNIQUE(account_id, form_id)
);

COMMENT ON TABLE client.configs IS
'Configuration Data for Accounts';

COMMIT;
