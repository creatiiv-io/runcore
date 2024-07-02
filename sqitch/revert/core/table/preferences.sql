-- Revert AppCore:core/table/preferences from pg

BEGIN;

DROP TABLE core.preferences;

COMMIT;
