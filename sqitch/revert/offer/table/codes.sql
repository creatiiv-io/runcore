-- Revert AppCore:offer/table/codes from pg

BEGIN;

DROP TABLE offer.codes;

COMMIT;
