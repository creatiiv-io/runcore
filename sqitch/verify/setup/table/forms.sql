-- Verify AppCore:setup/table/forms on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT 1 + count(*) FROM setup.forms
  ), 'Missing setup.forms table';
END $$;

ROLLBACK;
