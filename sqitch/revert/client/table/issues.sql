-- Revert AppCore:client/table/issues from pg

BEGIN;

DROP TABLE client.issues;

COMMIT;
