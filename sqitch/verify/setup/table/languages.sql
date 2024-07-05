-- Verify AppCore:setup/table/languages on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.languages'))
  ), 'Missing setup.languages table';
END $$;

ROLLBACK;
