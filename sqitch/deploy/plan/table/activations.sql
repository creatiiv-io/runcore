-- Deploy AppCore:core/table/activations to pg

BEGIN;

CREATE TABLE core.activations (
  code uuid PRIMARY KEY REFERENCES core.codes(code),
  account_id uuid NOT NULL REFERENCES core.accounts(id),

  activated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE core.activations
IS 'User Preferences with sorting';

COMMIT;
