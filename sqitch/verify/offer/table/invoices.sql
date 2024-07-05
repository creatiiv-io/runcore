-- Verify AppCore:offer/table/invoices on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.invoices'))
  ), 'Missing offer.invoices table';
END $$;

ROLLBACK;
