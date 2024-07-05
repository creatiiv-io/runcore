-- Revert AppCore:core/table/agreements from pg

BEGIN;

DROP TABLE core.agreements;

COMMIT;
