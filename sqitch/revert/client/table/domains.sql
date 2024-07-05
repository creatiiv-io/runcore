-- Revert AppCore:client/table/domains from pg

BEGIN;

DROP TABLE client.domains;

COMMIT;
