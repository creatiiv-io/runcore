-- Revert AppCore:setup/table/features from pg

BEGIN;

DROP TABLE setup.features;

COMMIT;
