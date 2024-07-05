-- Revert AppCore:core/table/webhooks from pg

BEGIN;

DROP TABLE core.webhooks;

COMMIT;
