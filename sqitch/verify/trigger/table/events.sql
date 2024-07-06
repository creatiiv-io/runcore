-- Verify AppCore:trigger/table/events on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('trigger.events'))
  ), 'Missing trigger.events table';
END $$;

ROLLBACK;
