-- Revert AppCore:setup/table/settings from pg

BEGIN;

DROP TABLE setup.settings;

COMMIT;
