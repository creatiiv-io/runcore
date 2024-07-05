-- Verify AppCore:core/table/plans on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.plans'))
  ), 'Missing core.plans table';
END $$;

ROLLBACK;
