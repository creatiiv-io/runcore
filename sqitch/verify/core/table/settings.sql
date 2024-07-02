-- Verify AppCore:core/table/settings on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.settings'))
  ), 'Missing core.settings table';
END $$;

ROLLBACK;
