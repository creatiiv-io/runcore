-- Verify AppCore:core/table/codes on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.codes'))
  ), 'Missing core.codes table';
END $$;

ROLLBACK;
