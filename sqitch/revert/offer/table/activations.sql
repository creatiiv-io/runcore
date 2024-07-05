-- Revert AppCore:offer/table/activations from pg

BEGIN;

DROP TABLE offer.activations;

COMMIT;
