-- Verify AppCore:core/table/forms on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT 1 + count(*) FROM core.forms
  ), 'Missing core.forms table';
END $$;

ROLLBACK;
