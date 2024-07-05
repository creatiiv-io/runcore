-- Revert AppCore:core/function/accounts_settings from pg

BEGIN;

DROP FUNCTION core.accounts_settings(account core.accounts);

COMMIT;
