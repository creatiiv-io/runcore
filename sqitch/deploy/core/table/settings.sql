-- Deploy AppCore:core/table/settings to pg

BEGIN;

CREATE TABLE core.settings (
  id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

  sorting SERIAL,
  category text,
  name text NOT NULL,
  description text NOT NULL,

  feature_id uuid REFERENCES core.features(id),

  datatype text NOT NULL CHECK (datatype IN ('number','string','boolean')),
  value jsonb NOT NULL
);

COMMENT ON TABLE core.settings
IS 'Settings with sorting';

COMMIT;
