-- Verify AppCore:core/table/users_changed_preferences on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.users_changed_preferences'))
  ), 'Missing core.users_changed_preferences table';
END $$;

ROLLBACK;
