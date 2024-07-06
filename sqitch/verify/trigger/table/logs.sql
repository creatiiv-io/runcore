-- Verify AppCore:trigger/table/logs on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('trigger.logs'))
  ), 'Missing trigger.logs table';
END $$;

ROLLBACK;
