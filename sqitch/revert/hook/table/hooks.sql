-- Revert AppCore:hook/table/hooks from pg

BEGIN;

DROP TABLE hook.hooks;

COMMIT;
