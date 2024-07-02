-- Revert AppCore:core/table/accounts_have_users from pg

BEGIN;

DROP TABLE core.accounts_have_users;

COMMIT;
