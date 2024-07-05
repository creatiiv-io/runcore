-- Verify AppCore:core/table/columns on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.columns'))
  ), 'Missing core.columns table';
END $$;

ROLLBACK;
