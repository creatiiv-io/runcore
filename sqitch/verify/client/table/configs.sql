-- Verify AppCore:client/table/configs on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.configs'))
  ), 'Missing client.configs table';
END $$;

ROLLBACK;
