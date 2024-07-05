-- Revert AppCore:offer/table/agreements from pg

BEGIN;

DROP TABLE offer.agreements;

COMMIT;
