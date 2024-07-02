-- Verify AppCore:core/table/invoices on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.invoices'))
  ), 'Missing core.invoices table';
END $$;

ROLLBACK;
