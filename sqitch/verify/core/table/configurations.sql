-- Verify AppCore:core/table/configurations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.configurations'))
  ), 'Missing core.configurations table';
END $$;

ROLLBACK;
