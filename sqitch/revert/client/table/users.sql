-- Revert AppCore:client/table/users from pg

BEGIN;

DROP TABLE client.users;

COMMIT;
