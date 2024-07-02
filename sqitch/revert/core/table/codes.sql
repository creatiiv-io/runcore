-- Revert AppCore:core/table/codes from pg

BEGIN;

DROP TABLE core.codes;

COMMIT;
