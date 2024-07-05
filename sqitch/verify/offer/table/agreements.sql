-- Verify AppCore:offer/table/agreements on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.agreements'))
  ), 'Missing offer.agreements table';
END $$;

ROLLBACK;
