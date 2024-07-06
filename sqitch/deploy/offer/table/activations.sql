-- Deploy AppCore:offer/table/activations to pg

BEGIN;

CREATE TABLE offer.activations (
  code uuid PRIMARY KEY REFERENCES offer.codes(code),
  account_id uuid NOT NULL REFERENCES client.accounts(id),

  activated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE offer.activations
IS 'User Preferences with sorting';

COMMIT;
