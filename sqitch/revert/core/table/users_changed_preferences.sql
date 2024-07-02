-- Revert AppCore:core/table/users_changed_preferences from pg

BEGIN;

DROP TABLE core.users_changed_preferences;

COMMIT;
