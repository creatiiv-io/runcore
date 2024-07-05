-- Verify AppCore:offer/table/signatures on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.signatures'))
  ), 'Missing offer.signatures table';
END $$;

ROLLBACK;
