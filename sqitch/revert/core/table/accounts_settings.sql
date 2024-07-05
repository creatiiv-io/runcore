-- Revert AppCore:core/table/accounts_settings from pg

BEGIN;

DROP TABLE core.accounts_settings;

COMMIT;
