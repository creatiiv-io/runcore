-- Verify AppCore:trigger/table/hooks on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('trigger.hooks'))
  ), 'Missing trigger.hooks table';
END $$;

ROLLBACK;
