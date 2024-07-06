-- Revert AppCore:trigger/table/logs from pg

BEGIN;

DROP TABLE trigger.logs;

COMMIT;
