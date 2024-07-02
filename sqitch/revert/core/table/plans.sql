-- Revert AppCore:core/table/plans from pg

BEGIN;

DROP TABLE core.plans;

COMMIT;
