-- Deploy AppCore:setup/table/preferences to pg

BEGIN;

CREATE TABLE setup.preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  category text,
  name text NOT NULL,
  description text NOT NULL,

  feature_id uuid REFERENCES setup.features(id),

  datatype text NOT NULL,
  value jsonb NOT NULL
);

COMMENT ON TABLE setup.preferences
IS 'User Preferences with sorting';

COMMIT;
