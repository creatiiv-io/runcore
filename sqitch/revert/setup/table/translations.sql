-- Revert AppCore:setup/table/translations from pg

BEGIN;

DROP TABLE setup.translations;

COMMIT;
