-- Verify AppCore:core/table/accounts_users on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.accounts_users'))
  ), 'Missing core.accounts_users table';
END $$;

ROLLBACK;
