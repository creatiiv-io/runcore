-- Revert AppCore:core/schema from pg

BEGIN;

DROP SCHEMA core;

COMMIT;
