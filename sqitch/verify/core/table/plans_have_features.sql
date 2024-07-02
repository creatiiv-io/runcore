-- Verify AppCore:core/table/plans_have_features on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.plans_have_features'))
  ), 'Missing core.plans_have_features table';
END $$;

ROLLBACK;
