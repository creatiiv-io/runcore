-- Verify AppCore:core/schema on pg

BEGIN;

DO $$
BEGIN
  ASSERT (
    SELECT has_schema_privilege('core', 'usage')
  ), 'falied to create core';
END $$;

ROLLBACK;
