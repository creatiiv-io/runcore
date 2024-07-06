-- Deploy AppCore:setup/table/features to pg

BEGIN;

CREATE TABLE setup.features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  name text UNIQUE NOT NULL,
  description text NOT NULL,

  amount smallint NOT NULL
);

COMMENT ON TABLE setup.features IS
'Feaatures that a plan may Include';

COMMIT;
