-- Revert AppCore:client/function/accounts_settings from pg

BEGIN;

DROP FUNCTION client.accounts_settings(account client.accounts);

COMMIT;
