-- Deploy AppCore:core/table/preferences to pg

BEGIN;

CREATE TABLE core.preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  category text,
  name text NOT NULL,
  description text NOT NULL,

  feature_id uuid REFERENCES core.features(id),

  datatype text NOT NULL,
  value jsonb NOT NULL
);

COMMENT ON TABLE core.preferences
IS 'User Preferences with sorting';

COMMIT;
