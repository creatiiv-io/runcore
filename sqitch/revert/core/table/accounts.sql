-- Revert AppCore:core/table/accounts from pg

BEGIN;

DROP TABLE core.accounts;

COMMIT;
