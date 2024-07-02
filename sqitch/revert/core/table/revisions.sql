-- Revert AppCore:core/table/revisions from pg

BEGIN;

DROP TABLE core.revisions;

COMMIT;
