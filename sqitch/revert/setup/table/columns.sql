-- Revert AppCore:setup/table/columns from pg

BEGIN;

DROP TABLE setup.columns;

COMMIT;
