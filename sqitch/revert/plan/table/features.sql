-- Revert AppCore:core/table/plans_features from pg

BEGIN;

DROP TABLE core.plans_features;

COMMIT;
