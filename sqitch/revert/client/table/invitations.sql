-- Revert AppCore:client/table/invitations from pg

BEGIN;

DROP TABLE client.invitations;

COMMIT;
