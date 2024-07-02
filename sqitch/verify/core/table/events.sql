-- Verify AppCore:core/table/events on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.events'))
  ), 'Missing core.events table';
END $$;

ROLLBACK;
