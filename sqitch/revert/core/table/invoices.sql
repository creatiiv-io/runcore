-- Revert AppCore:core/table/invoices from pg

BEGIN;

DROP TABLE core.invoices;

COMMIT;
