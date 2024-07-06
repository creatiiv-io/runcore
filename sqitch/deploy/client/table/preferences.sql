-- Deploy AppCore:client/table/preferences to pg

BEGIN;

CREATE TABLE client.preferences (
  user_id uuid NOT NULL REFERENCES auth.users(id),
  preference_id uuid NOT NULL REFERENCES setup.preferences(id),

  value jsonb NOT NULL,

  UNIQUE(user_id, preference_id)
);

COMMENT ON TABLE client.preferences
IS 'Preferences set by user';

COMMIT;
