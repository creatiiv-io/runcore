-- Revert AppCore:setup/table/languages from pg

BEGIN;

DROP TABLE setup.languages;

COMMIT;
