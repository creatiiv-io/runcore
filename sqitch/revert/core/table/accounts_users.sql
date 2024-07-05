-- Revert AppCore:core/table/accounts_users from pg

BEGIN;

DROP TABLE core.accounts_users;

COMMIT;
