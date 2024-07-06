-- Revert AppCore:trigger/table/events from pg

BEGIN;

DROP TABLE trigger.events;

COMMIT;
