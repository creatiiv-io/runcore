-- schema main 
CREATE SCHEMA IF NOT EXISTS main;

-- necessary for hasura main to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA main
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA main TO "${RUNCORE_HASURA_USER}";

-- table main.accounts
BEGIN;
  CALL watch_create_table('main.accounts');

  CREATE TABLE main.accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    signup_number int GENERATED ALWAYS AS IDENTITY,
    referral_code shortcode UNIQUE NOT NULL,
    referred_by uuid REFERENCES main.accounts(id),

    name text NOT NULL,
    locale locale NOT NULL REFERENCES core.languages(code),

    is_active bool NOT NULL DEFAULT true,
    is_deleted bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE main.accounts
  IS 'Multi-main Accounts';

  CALL after_create_table('main.accounts');
COMMIT;

 -- table main.configs
 BEGIN;
   CALL watch_create_table('main.configs');
 
   CREATE TABLE main.configs (
     account_id uuid NOT NULL REFERENCES main.accounts(id),
     form_name entity_scoped NOT NULL REFERENCES core.forms(form),
     data jsonb NOT NULL,
 
     PRIMARY KEY (account_id, form_name)
   );
 
   COMMENT ON TABLE main.configs IS
   'Configuration Data for Accounts';
 
   CALL after_create_table('main.configs');
 COMMIT;
 
-- table main.domains
BEGIN;
  CALL watch_create_table('main.domains');

  CREATE TABLE main.domains (
    domain_name domain_name PRIMARY KEY,

    account_id uuid UNIQUE NOT NULL REFERENCES main.accounts(id),

    is_verified bool NOT NULL DEFAULT false,
    is_active bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE main.domains
  IS 'Domains that can be routed';

  CALL after_create_table('main.domains');
COMMIT;

-- table main.invitations
BEGIN;
  CALL watch_create_table('main.invitations');

  CREATE TABLE main.invitations (
    account_id uuid NOT NULL REFERENCES main.accounts(id),
    email email NOT NULL,

    role_name entity NOT NULL REFERENCES auth.roles(role),
    user_id uuid REFERENCES auth.users(id),

    invited_by uuid REFERENCES auth.users(id),

    UNIQUE(account_id, email)
  );

  COMMENT ON TABLE main.invitations
  IS 'Invitations to new Users';

  CALL after_create_table('main.invitations');
COMMIT;

-- table main.preferences
BEGIN;
  CALL watch_create_table('main.preferences');

  CREATE TABLE main.preferences (
    user_id uuid NOT NULL REFERENCES auth.users(id),
    preference entity NOT NULL REFERENCES core.preferences(preference),

    value jsonvalue NOT NULL,

    UNIQUE(user_id, preference)
  );

  COMMENT ON TABLE main.preferences
  IS 'Preferences set by main';

  CALL after_create_table('main.preferences');

  CREATE OR REPLACE TRIGGER main_preferences_value
  BEFORE UPDATE ON main.preferences
  FOR EACH ROW EXECUTE FUNCTION value_to_jsonvalue();
COMMIT;

-- table main.settings
BEGIN;
  CALL watch_create_table('main.settings');

  CREATE TABLE main.settings (
    account_id uuid NOT NULL REFERENCES main.accounts(id),
    setting entity NOT NULL REFERENCES core.settings(setting),
    value jsonvalue NOT NULL,

    PRIMARY KEY (account_id, setting)
  );

  COMMENT ON TABLE main.settings
  IS 'Domains that can be routed';

  CALL after_create_table('main.settings');

  CREATE OR REPLACE TRIGGER main_settings_value
  BEFORE UPDATE ON main.settings
  FOR EACH ROW EXECUTE FUNCTION value_to_jsonvalue();
COMMIT;

-- table main.agents
BEGIN;
  CALL watch_create_table('main.agents');

  CREATE TABLE main.agents (
    account_id uuid NOT NULL REFERENCES main.accounts(id),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    role_name entity NOT NULL REFERENCES auth.roles(role),
    permit_id uuid NOT NULL REFERENCES auth.permits(id),

    PRIMARY KEY (account_id, user_id)
  );

  COMMENT ON TABLE main.agents
  IS 'Assign Users as Agents to Account with Role';

  CALL after_create_table('main.agents');
COMMIT;

-- function main.accounts_settings
CREATE OR REPLACE FUNCTION main.accounts_settings(rec main.accounts)
RETURNS SETOF core.settings AS $$
  SELECT
    cs.setting,
    cs.feature,
    cs.datatype,
    COALESCE(os.value, cs.value) AS value,
    cs.description
  FROM core.settings cs
  LEFT OUTER JOIN main.settings os
    ON (os.setting = cs.setting)
  WHERE os.account_id = rec.id;
$$ LANGUAGE sql STABLE;

-- function main.accounts_referal_code
CREATE OR REPLACE FUNCTION main.accounts_referral_code() 
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
BEFORE INSERT OR UPDATE ON main.accounts
FOR EACH ROW
EXECUTE FUNCTION main.accounts_referral_code();

-- function main.accounts_translation
CREATE OR REPLACE FUNCTION main.accounts_translation(rec main.accounts)
RETURNS jsonb AS $$
  SELECT core.translation(rec.locale)
  FROM (VALUES (rec)) as tmp(rec);
$$ LANGUAGE sql STABLE;

-- function main.users_translation
CREATE OR REPLACE FUNCTION main.users_translation(rec auth.users)
RETURNS jsonb AS $$
  SELECT core.translation(rec.locale)
  FROM (VALUES (rec)) AS tmp(rec);
$$ LANGUAGE sql STABLE;
