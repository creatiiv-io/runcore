-- Verify AppCore:core/table/accounts on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.accounts'))
  ), 'Missing core.accounts table';
END $$;

ROLLBACK;
