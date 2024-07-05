-- Revert AppCore:core/table/translations from pg

BEGIN;

DROP TABLE core.translations;

COMMIT;
