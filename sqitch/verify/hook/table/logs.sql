-- Verify AppCore:hook/table/logs on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('hook.logs'))
  ), 'Missing hook.logs table';
END $$;

ROLLBACK;
