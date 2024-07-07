-- Deploy AppCore:offer/table/codes to pg

BEGIN;

CREATE TABLE offer.codes (
  code_num uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  platform text NOT NULL,

  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL DEFAULT now() + INTERVAL '4 months'
);

COMMENT ON TABLE offer.codes IS
'Activation codes for marketing platform';

COMMIT;
