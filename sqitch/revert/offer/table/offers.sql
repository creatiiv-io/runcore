-- Revert AppCore:offer/table/plans from pg

BEGIN;

DROP TABLE offer.plans;

COMMIT;
