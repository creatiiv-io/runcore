-- Revert AppCore:core/table/events from pg

BEGIN;

DROP TABLE core.events;

COMMIT;
