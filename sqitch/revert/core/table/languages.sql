-- Revert AppCore:core/table/languages from pg

BEGIN;

DROP TABLE core.languages;

COMMIT;
