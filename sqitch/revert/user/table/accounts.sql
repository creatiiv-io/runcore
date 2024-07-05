-- Revert AppCore:user/table/accounts from pg

BEGIN;

DROP TABLE user.accounts;

COMMIT;
