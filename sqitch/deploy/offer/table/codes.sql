-- Deploy AppCore:offer/table/codes to pg

BEGIN;

CREATE TABLE offer.codes (
  code uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  platform text NOT NULL,

  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE offer.codes IS
'Activation codes for marketing platform';

COMMIT;
