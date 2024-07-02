-- Revert AppCore:core/table/plans_have_features from pg

BEGIN;

DROP TABLE core.plans_have_features;

COMMIT;
