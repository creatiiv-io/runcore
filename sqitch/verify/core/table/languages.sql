-- Verify AppCore:core/table/languages on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.languages'))
  ), 'Missing core.languages table';
END $$;

ROLLBACK;
