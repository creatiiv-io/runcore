-- Verify AppCore:offer/table/codes on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.codes'))
  ), 'Missing offer.codes table';
END $$;

ROLLBACK;
