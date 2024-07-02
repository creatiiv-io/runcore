-- Verify AppCore:core/table/agreements on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.agreements'))
  ), 'Missing core.agreements table';
END $$;

ROLLBACK;
