-- Deploy AppCore:core/table/users_preferences to pg

BEGIN;

CREATE TABLE core.users_preferences (
  user_id uuid NOT NULL REFERENCES auth.users(id),
  preference_id uuid NOT NULL REFERENCES core.preferences(id),

  value jsonb NOT NULL,

  UNIQUE(user_id, preference_id)
);

COMMENT ON TABLE core.users_preferences
IS 'Preferences set by user';

COMMIT;
