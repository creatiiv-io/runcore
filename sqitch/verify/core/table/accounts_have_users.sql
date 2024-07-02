-- Verify AppCore:core/table/accounts_have_users on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.accounts_have_users'))
  ), 'Missing core.accounts_have_users table';
END $$;

ROLLBACK;
