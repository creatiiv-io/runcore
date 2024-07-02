-- Verify AppCore:core/table/preferences on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.preferences'))
  ), 'Missing core.preferences table';
END $$;

ROLLBACK;
