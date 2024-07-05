-- Verify AppCore:setup/table/preferences on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.preferences'))
  ), 'Missing setup.preferences table';
END $$;

ROLLBACK;
