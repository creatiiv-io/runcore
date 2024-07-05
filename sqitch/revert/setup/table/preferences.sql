-- Revert AppCore:setup/table/preferences from pg

BEGIN;

DROP TABLE setup.preferences;

COMMIT;
