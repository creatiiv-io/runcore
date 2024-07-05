-- Deploy AppCore:core/table/accounts_users to pg

BEGIN;

CREATE TABLE core.accounts_users (
  account_id uuid NOT NULL REFERENCES core.accounts(id),
  user_id uuid NOT NULL REFERENCES auth.users(id),

  role_name text NOT NULL REFERENCES auth.roles(role),

  UNIQUE (account_id, user_id)
);

COMMENT ON TABLE core.accounts_users
IS 'Users allowed to access an Account';

COMMIT;
