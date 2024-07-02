-- Revert AppCore:core/table/invitations from pg

BEGIN;

DROP TABLE core.invitations;

COMMIT;
