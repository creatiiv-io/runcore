-- Verify AppCore:core/table/users_preferences on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.users_preferences'))
  ), 'Missing core.users_preferences table';
END $$;

ROLLBACK;
