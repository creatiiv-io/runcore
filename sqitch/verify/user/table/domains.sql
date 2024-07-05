-- Verify AppCore:core/table/domains on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.domains'))
  ), 'Missing core.domains table';
END $$;

ROLLBACK;
