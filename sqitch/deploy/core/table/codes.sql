-- Deploy AppCore:core/table/codes to pg

BEGIN;

CREATE TABLE core.codes (
  code uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  platform text NOT NULL,

  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE core.codes IS
'Activation codes for marketing platform';

COMMIT;
