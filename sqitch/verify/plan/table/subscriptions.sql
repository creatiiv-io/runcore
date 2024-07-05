-- Verify AppCore:core/table/subscriptions on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.subscriptions'))
  ), 'Missing core.subscriptions table';
END $$;

ROLLBACK;
