-- user schema
CREATE SCHEMA IF NOT EXISTS user;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA user
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA user TO "${RUNCORE_HASURA_USER}";

-- user.accounts
BEGIN;
  CALL watch_create_table('user.accounts');

  CREATE TABLE user.accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    signup_number int GENERATED ALWAYS AS IDENTITY,
    referral_code shortcode UNIQUE NOT NULL,
    referred_by uuid REFERENCES user.accounts(id),

    name text NOT NULL,
    language_code locale NOT NULL REFERENCES setup.languages(code),

    is_active bool NOT NULL DEFAULT true,
    is_deleted bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE user.accounts
  IS 'Multi-user Accounts';

  CALL after_create_table('user.accounts');
COMMIT;

-- function user.accounts_referal_code
CREATE OR REPLACE FUNCTION user.accounts_referral_code() 
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the referral_code is null
  IF NEW.referral_code IS NULL THEN
    -- Calculate the referral_code using the sharecode function
    NEW.referral_code := sharecode(NEW.signup_number);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger accounts_referral_code_check
CREATE OR REPLACE TRIGGER accounts_referral_code_check
BEFORE INSERT OR UPDATE ON user.accounts
FOR EACH ROW
EXECUTE FUNCTION user.accounts_referral_code();

-- function user.accounts_settings
CREATE OR REPLACE FUNCTION user.accounts_settings(account user.accounts)
RETURNS SETOF core.settings AS $$
  SELECT
    cs.setting,
    cs.feature,
    cs.datatype,
    COALESCE(us.value, cs.value) AS value,
    cs.description
  FROM cpre.settings cs
  LEFT OUTER JOIN user.settings us
    ON (us.setting = cs.setting)
  WHERE us.account_id = account.id;
$$ LANGUAGE sql STABLE;

-- function user.accounts_translation
CREATE OR REPLACE FUNCTION user.accounts_translation(account user.accounts)
RETURNS jsonb AS $$
  SELECT core.translation(account.language);
$$ LANGUAGE sql STABLE;

 -- table user.configs
 BEGIN;
   CALL watch_create_table('user.configs');
 
   CREATE TABLE user.configs (
     account_id uuid NOT NULL REFERENCES user.accounts(id),
     form_name entity_scoped NOT NULL REFERENCES setup.forms(form),
 
     data jsonb NOT NULL,
 
     UNIQUE(account_id, form)
   );
 
   COMMENT ON TABLE user.configs IS
   'Configuration Data for Accounts';
 
   CALL after_create_table('user.configs');
 COMMIT;
 
-- table user.domains
BEGIN;
  CALL watch_create_table('user.domains');

  CREATE TABLE user.domains (
    domain_name domain_name PRIMARY KEY,

    account_id uuid UNIQUE NOT NULL REFERENCES user.accounts(id),

    is_verified bool NOT NULL DEFAULT false,
    is_active bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE user.domains
  IS 'Domains that can be routed';

  CALL after_create_table('user.domains');
COMMIT;

-- table user.invitations
BEGIN;
  CALL watch_create_table('user.invitations');

  CREATE TABLE user.invitations (
    account_id uuid NOT NULL REFERENCES user.accounts(id),
    email email NOT NULL,

    role_name entity NOT NULL REFERENCES auth.roles(role),
    user_id uuid REFERENCES auth.users(id),

    invited_by uuid REFERENCES auth.users(id),

    UNIQUE(account_id, email)
  );

  COMMENT ON TABLE user.invitations
  IS 'Invitations to new Users';

  CALL after_create_table('user.invitations');
COMMIT;

-- table user.preferences
BEGIN;
  CALL watch_create_table('user.preferences');

  CREATE TABLE user.preferences (
    user_id uuid NOT NULL REFERENCES auth.users(id),
    preference entity NOT NULL REFERENCES setup.preferences(preference),

    value jsonvalue NOT NULL,

    UNIQUE(user_id, preference)
  );

  COMMENT ON TABLE user.preferences
  IS 'Preferences set by user';

  CALL after_create_table('user.preferences');
COMMIT;

-- table user.settings
BEGIN;
  CALL watch_create_table('user.settings');

  CREATE TABLE user.settings (
    account_id uuid NOT NULL REFERENCES user.accounts(id),
    setting entity NOT NULL REFERENCES setup.settings(id),

    value jsonvalue NOT NULL,

    UNIQUE (account_id, setting_id)
  );

  COMMENT ON TABLE user.settings
  IS 'Domains that can be routed';

  CALL after_create_table('user.settings');
COMMIT;

-- table user.users
BEGIN;
  CALL watch_create_table('user.users');

  CREATE TABLE user.users (
    account_id uuid NOT NULL REFERENCES user.accounts(id),
    user_id uuid NOT NULL REFERENCES auth.users(id),

    role entity NOT NULL REFERENCES auth.roles(role),

    UNIQUE (account_id, user_id)
  );

  COMMENT ON TABLE user.users
  IS 'Users allowed to access an Account';

  CALL after_create_table('user.users');
COMMIT;

-- function user.users_translation
CREATE OR REPLACE FUNCTION user.accounts_translation(user auth.users)
RETURNS jsonb AS $$
  SELECT core.translation(user.locale);
$$ LANGUAGE sql STABLE;
