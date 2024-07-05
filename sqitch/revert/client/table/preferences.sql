-- Revert AppCore:client/table/preferences from pg

BEGIN;

DROP TABLE client.preferences;

COMMIT;
