-- Verify AppCore:client/table/domains on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.domains'))
  ), 'Missing client.domains table';
END $$;

ROLLBACK;
