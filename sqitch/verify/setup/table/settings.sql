-- Verify AppCore:setup/table/settings on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.settings'))
  ), 'Missing setup.settings table';
END $$;

ROLLBACK;
