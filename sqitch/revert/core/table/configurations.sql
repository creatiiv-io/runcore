-- Revert AppCore:core/table/configurations from pg

BEGIN;

DROP TABLE core.configurations;

COMMIT;
