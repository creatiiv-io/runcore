-- client schema
CREATE SCHEMA IF NOT EXISTS client;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA client
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA client TO "${RUNCORE_HASURA_USER}";

-- client.accounts
BEGIN;
  CALL watch_create_table('client.accounts');

  CREATE TABLE client.accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    signup_number int GENERATED ALWAYS AS IDENTITY,
    referral_code text,
    referred_by uuid REFERENCES client.accounts(id),

    name text NOT NULL,
    language_code varchar(2) NOT NULL REFERENCES setup.languages(code),

    is_active bool NOT NULL DEFAULT true,
    is_deleted bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE client.accounts
  IS 'Multi-user Accounts';

  CALL after_create_table('client.accounts');
COMMIT;

 -- table client.configs
 BEGIN;
   CALL watch_create_table('client.configs');
 
   CREATE TABLE client.configs (
     account_id uuid NOT NULL REFERENCES client.accounts(id),
     form_id uuid NOT NULL REFERENCES setup.forms(id),
 
     data jsonb NOT NULL,
 
     UNIQUE(account_id, form_id)
   );
 
   COMMENT ON TABLE client.configs IS
   'Configuration Data for Accounts';
 
   CALL after_create_table('client.configs');
 COMMIT;
 
-- table client.domains
BEGIN;
  CALL watch_create_table('client.domains');

  CREATE TABLE client.domains (
    domain_name text PRIMARY KEY,

    account_id uuid UNIQUE NOT NULL REFERENCES client.accounts(id),

    is_verified bool NOT NULL DEFAULT false,
    is_active bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE client.domains
  IS 'Domains that can be routed';

  CALL after_create_table('client.domains');
COMMIT;

-- table client.invitations
BEGIN;
  CALL watch_create_table('client.invitations');

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

  CALL after_create_table('client.invitations');
COMMIT;

-- table client.preferences
BEGIN;
  CALL watch_create_table('client.preferences');

  CREATE TABLE client.preferences (
    user_id uuid NOT NULL REFERENCES auth.users(id),
    preference_id uuid NOT NULL REFERENCES setup.preferences(id),

    value jsonb NOT NULL,

    UNIQUE(user_id, preference_id)
  );

  COMMENT ON TABLE client.preferences
  IS 'Preferences set by user';

  CALL after_create_table('client.preferences');
COMMIT;

-- table client.settings
BEGIN;
  CALL watch_create_table('client.settings');

  CREATE TABLE client.settings (
    account_id uuid NOT NULL REFERENCES client.accounts(id),
    setting_id uuid NOT NULL REFERENCES setup.settings(id),

    value jsonb NOT NULL,

    UNIQUE (account_id, setting_id)
  );

  COMMENT ON TABLE client.settings
  IS 'Domains that can be routed';

  CALL after_create_table('client.settings');
COMMIT;

-- table client.users
BEGIN;
  CALL watch_create_table('client.users');

  CREATE TABLE client.users (
    account_id uuid NOT NULL REFERENCES client.accounts(id),
    user_id uuid NOT NULL REFERENCES auth.users(id),

    role_name text NOT NULL REFERENCES auth.roles(role),

    UNIQUE (account_id, user_id)
  );

  COMMENT ON TABLE client.users
  IS 'Users allowed to access an Account';

  CALL after_create_table('client.users');
COMMIT;

-- function client.accounts_settings
CREATE OR REPLACE FUNCTION client.accounts_settings(account client.accounts)
RETURNS SETOF setup.settings AS $$
  SELECT
    cs.id,
    cs.sorting,
    cs.category,
    cs.name,
    cs.description,
    cs.feature_id,
    cs.datatype,
    COALESCE(us.value, cs.value) AS value
  FROM setup.settings cs
  LEFT OUTER JOIN client.settings us
    ON (us.setting_id = cs.id)
  WHERE us.account_id = account.id;
$$ LANGUAGE sql STABLE;
