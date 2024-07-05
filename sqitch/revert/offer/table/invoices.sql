-- Revert AppCore:offer/table/invoices from pg

BEGIN;

DROP TABLE offer.invoices;

COMMIT;
