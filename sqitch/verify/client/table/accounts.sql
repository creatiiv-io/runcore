-- Verify AppCore:client/table/accounts on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.accounts'))
  ), 'Missing client.accounts table';
END $$;

ROLLBACK;
