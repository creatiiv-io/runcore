-- Verify AppCore:offer/table/subscriptions on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.subscriptions'))
  ), 'Missing offer.subscriptions table';
END $$;

ROLLBACK;
