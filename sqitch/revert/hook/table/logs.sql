-- Revert AppCore:core/table/runlogs from pg

BEGIN;

DROP TABLE core.runlogs;

COMMIT;
