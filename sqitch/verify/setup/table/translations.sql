-- Verify AppCore:setup/table/translations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('setup.translations'))
  ), 'Missing setup.translations table';
END $$;

ROLLBACK;
