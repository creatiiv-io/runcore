-- Verify AppCore:client/table/settings on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.settings'))
  ), 'Missing client.settings table';
END $$;

ROLLBACK;
