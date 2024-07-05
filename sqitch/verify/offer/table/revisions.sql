-- Verify AppCore:offer/table/revisions on pg

BEGIN;

DO $$ BEGIN
  ASSERT (
    SELECT count(to_regclass('offer.revisions'))
  ), 'Missing offer.revisions table';
END $$;

ROLLBACK;
