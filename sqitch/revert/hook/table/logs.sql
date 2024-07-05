-- Revert AppCore:hook/table/logs from pg

BEGIN;

DROP TABLE hook.logs;

COMMIT;
