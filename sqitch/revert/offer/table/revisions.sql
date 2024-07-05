-- Revert AppCore:offer/table/revisions from pg

BEGIN;

DROP TABLE offer.revisions;

COMMIT;
