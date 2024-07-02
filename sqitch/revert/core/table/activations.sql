-- Revert AppCore:core/table/activations from pg

BEGIN;

DROP TABLE core.activations;

COMMIT;
