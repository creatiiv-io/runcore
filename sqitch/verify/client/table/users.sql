-- Verify AppCore:client/table/users on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.users'))
  ), 'Missing client.users table';
END $$;

ROLLBACK;
