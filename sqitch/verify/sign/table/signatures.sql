-- Verify AppCore:core/table/signatures on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.signatures'))
  ), 'Missing core.signatures table';
END $$;

ROLLBACK;
