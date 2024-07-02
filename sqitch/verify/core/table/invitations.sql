-- Verify AppCore:core/table/invitations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.invitations'))
  ), 'Missing core.invitations table';
END $$;

ROLLBACK;
