-- Verify AppCore:core/table/accounts_changed_settings on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.accounts_changed_settings'))
  ), 'Missing core.accounts_changed_settings table';
END $$;

ROLLBACK;
