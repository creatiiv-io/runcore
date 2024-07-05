-- Revert AppCore:core/table/users_preferences from pg

BEGIN;

DROP TABLE core.users_preferences;

COMMIT;
