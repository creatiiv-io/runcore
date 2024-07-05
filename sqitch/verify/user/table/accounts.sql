-- Verify AppCore:user/table/accounts on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('user.accounts'))
  ), 'Missing user.accounts table';
END $$;

ROLLBACK;
