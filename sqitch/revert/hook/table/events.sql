-- Revert AppCore:hook/table/events from pg

BEGIN;

DROP TABLE hook.events;

COMMIT;
