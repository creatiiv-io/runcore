-- Revert AppCore:core/table/accounts_changed_settings from pg

BEGIN;

DROP TABLE core.accounts_changed_settings;

COMMIT;
