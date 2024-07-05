-- Deploy AppCore:client/table/preferences to pg

BEGIN;

CREATE TABLE client.preferences (
  user_id uuid NOT NULL REFERENCES auth.users(id),
  preference_id uuid NOT NULL REFERENCES core.preferences(id),

  value jsonb NOT NULL,

  UNIQUE(user_id, preference_id)
);

COMMENT ON TABLE clientpreferences
IS 'Preferences set by user';

COMMIT;
