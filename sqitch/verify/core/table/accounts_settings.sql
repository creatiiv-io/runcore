-- Verify AppCore:core/table/accounts_settings on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.accounts_settings'))
  ), 'Missing core.accounts_settings table';
END $$;

ROLLBACK;
