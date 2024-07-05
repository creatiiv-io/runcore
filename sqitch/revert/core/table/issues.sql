-- Revert AppCore:core/table/issues from pg

BEGIN;

DROP TABLE core.issues;

COMMIT;
