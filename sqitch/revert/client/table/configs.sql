-- Revert AppCore:client/table/configs from pg

BEGIN;

DROP TABLE client.configs;

COMMIT;
