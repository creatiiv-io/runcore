-- Revert AppCore:core/table/columns from pg

BEGIN;

DROP TABLE core.columns;

COMMIT;
