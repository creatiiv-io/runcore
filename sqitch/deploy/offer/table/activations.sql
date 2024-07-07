-- Deploy AppCore:offer/table/activations to pg

BEGIN;

CREATE TABLE offer.activations (
  code_num uuid PRIMARY KEY REFERENCES offer.codes(code_num),
  account_id uuid NOT NULL REFERENCES client.accounts(id),

  activated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE offer.activations
IS 'User Preferences with sorting';

COMMIT;
