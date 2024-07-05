-- Verify AppCore:offer/table/activations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.activations'))
  ), 'Missing offer.activations table';
END $$;

ROLLBACK;
