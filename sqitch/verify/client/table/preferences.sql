-- Verify AppCore:client/table/preferences on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.preferences'))
  ), 'Missing client.preferences table';
END $$;

ROLLBACK;
