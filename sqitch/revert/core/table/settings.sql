-- Revert AppCore:core/table/settings from pg

BEGIN;

DROP TABLE core.settings;

COMMIT;
