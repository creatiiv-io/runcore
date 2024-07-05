-- Deploy AppCore:client/table/invitations to pg

BEGIN;

CREATE TABLE client.invitations (
  account_id uuid NOT NULL REFERENCES client.accounts(id),
  email text NOT NULL,

  role_name text NOT NULL REFERENCES auth.roles(role),
  user_id uuid REFERENCES auth.users(id),

  invited_by uuid REFERENCES auth.users(id),

  UNIQUE(account_id, email)
);

COMMENT ON TABLE client.invitations
IS 'Invitations to new Users';


COMMIT;
