-- Revert AppCore:core/table/subscriptions from pg

BEGIN;

DROP TABLE core.subscriptions;

COMMIT;
