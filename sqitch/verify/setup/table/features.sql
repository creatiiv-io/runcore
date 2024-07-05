-- Verify AppCore:setup/table/features on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.features'))
  ), 'Missing setup.features table';
END $$;

ROLLBACK;
