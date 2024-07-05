-- Verify AppCore:client/table/issues on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.issues'))
  ), 'Missing client.issues table';
END $$;

ROLLBACK;
