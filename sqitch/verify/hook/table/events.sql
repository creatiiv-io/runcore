-- Verify AppCore:hook/table/events on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('hook.events'))
  ), 'Missing hook.events table';
END $$;

ROLLBACK;
