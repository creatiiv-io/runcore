-- Verify AppCore:core/table/translations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.translations'))
  ), 'Missing core.translations table';
END $$;

ROLLBACK;
