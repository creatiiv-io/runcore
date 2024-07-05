-- Revert AppCore:core/table/domains from pg

BEGIN;

DROP TABLE core.domains;

COMMIT;
