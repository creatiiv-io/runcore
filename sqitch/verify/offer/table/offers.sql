-- Verify AppCore:offer/table/plans on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.plans'))
  ), 'Missing offer.plans table';
END $$;

ROLLBACK;
