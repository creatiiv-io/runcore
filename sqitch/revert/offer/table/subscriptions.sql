-- Revert AppCore:offer/table/subscriptions from pg

BEGIN;

DROP TABLE offer.subscriptions;

COMMIT;
