-- Verify AppCore:offer/table/features on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.features'))
  ), 'Missing offer.features table';
END $$;

ROLLBACK;
