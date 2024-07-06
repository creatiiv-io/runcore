-- Revert AppCore:trigger/table/hooks from pg

BEGIN;

DROP TABLE trigger.hooks;

COMMIT;
