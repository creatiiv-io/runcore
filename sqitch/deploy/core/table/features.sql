-- Deploy AppCore:core/table/features to pg

BEGIN;

CREATE TABLE core.features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  name text UNIQUE NOT NULL,
  description text NOT NULL,

  ammount smallint NOT NULL
);

COMMENT ON TABLE core.features IS
'Feaatures that a plan may Include';

COMMIT;
