-- Verify AppCore:core/table/plans_features on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.plans_features'))
  ), 'Missing core.plans_features table';
END $$;

ROLLBACK;
