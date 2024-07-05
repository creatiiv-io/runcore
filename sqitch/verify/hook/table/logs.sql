-- Verify AppCore:core/table/runlogs on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.runlogs'))
  ), 'Missing core.runlogs table';
END $$;

ROLLBACK;
