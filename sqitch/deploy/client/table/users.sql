-- Deploy AppCore:client/table/users to pg

BEGIN;

CREATE TABLE client.users (
  account_id uuid NOT NULL REFERENCES client.accounts(id),
  user_id uuid NOT NULL REFERENCES auth.client(id),

  role_name text NOT NULL REFERENCES auth.roles(role),

  UNIQUE (account_id, user_id)
);

COMMENT ON TABLE client.users
IS 'Users allowed to access an Account';

COMMIT;
