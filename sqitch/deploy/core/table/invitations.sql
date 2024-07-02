-- Deploy AppCore:core/table/invitations to pg

BEGIN;

CREATE TABLE core.invitations (
  account_id uuid NOT NULL REFERENCES core.accounts(id),
  email text NOT NULL,

  role text NOT NULL REFERENCES auth.roles(role),
  user_id uuid REFERENCES auth.users(id),

  invited_by uuid REFERENCES auth.users(id),

  UNIQUE(account_id, email)
);

COMMENT ON TABLE core.invitations
IS 'Invitations to new Users';


COMMIT;
