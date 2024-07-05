-- Revert AppCore:offer/table/features from pg

BEGIN;

DROP TABLE offer.features;

COMMIT;
