-- Verify AppCore:core/table/webhooks on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('core.webhooks'))
  ), 'Missing core.webhooks table';
END $$;

ROLLBACK;
