-- Revert AppCore:client/table/accounts from pg

BEGIN;

DROP TABLE client.accounts;

COMMIT;
