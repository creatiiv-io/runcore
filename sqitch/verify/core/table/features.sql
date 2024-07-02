-- Verify AppCore:core/table/features on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.features'))
  ), 'Missing core.features table';
END $$;

ROLLBACK;
