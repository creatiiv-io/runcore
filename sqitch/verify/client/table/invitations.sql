-- Verify AppCore:client/table/invitations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('client.invitations'))
  ), 'Missing client.invitations table';
END $$;

ROLLBACK;
