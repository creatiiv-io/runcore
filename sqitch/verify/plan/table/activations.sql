-- Verify AppCore:core/table/activations on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.activations'))
  ), 'Missing core.activations table';
END $$;

ROLLBACK;
