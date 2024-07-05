-- Revert AppCore:offer/table/signatures from pg

BEGIN;

DROP TABLE offer.signatures;

COMMIT;
