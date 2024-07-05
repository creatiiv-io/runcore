-- Revert AppCore:client/table/settings from pg

BEGIN;

DROP TABLE client.settings;

COMMIT;
