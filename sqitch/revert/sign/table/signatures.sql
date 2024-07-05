-- Revert AppCore:core/table/signatures from pg

BEGIN;

DROP TABLE core.signatures;

COMMIT;
