-- Verify AppCore:setup/table/columns on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.columns'))
  ), 'Missing setup.columns table';
END $$;

ROLLBACK;
