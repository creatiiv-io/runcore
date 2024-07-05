-- Verify AppCore:hook/table/hooks on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('hook.hooks'))
  ), 'Missing hook.hooks table';
END $$;

ROLLBACK;
