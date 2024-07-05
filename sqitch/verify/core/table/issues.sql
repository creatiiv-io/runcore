-- Verify AppCore:core/table/issues on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.issues'))
  ), 'Missing core.issues table';
END $$;

ROLLBACK;
