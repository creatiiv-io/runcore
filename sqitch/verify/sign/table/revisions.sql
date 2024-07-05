-- Verify AppCore:core/table/revisions on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.revisions'))
  ), 'Missing core.revisions table';
END $$;

ROLLBACK;
