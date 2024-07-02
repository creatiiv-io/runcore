-- Deploy AppCore:core/table/configurations to pg

BEGIN;

CREATE TABLE core.configurations (
  account_id uuid NOT NULL REFERENCES core.accounts(id),
  form_id uuid NOT NULL REFERENCES core.forms(id),

  data jsonb NOT NULL,

  UNIQUE(account_id, form_id)
);

COMMENT ON TABLE core.configurations IS
'Configuration Data for Accounts';

COMMIT;
