-- Revert AppCore:core/table/features from pg

BEGIN;

DROP TABLE core.features;

COMMIT;
