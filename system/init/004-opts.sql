-- schema opts 
CREATE SCHEMA IF NOT EXISTS opts;

-- necessary for hasura opts to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA opts
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA opts TO "${RUNCORE_HASURA_USER}";

-- table opts.accounts
BEGIN;
  CALL watch_create_table('opts.accounts');

  CREATE TABLE opts.accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    signup_number int GENERATED ALWAYS AS IDENTITY,
    referral_code shortcode UNIQUE NOT NULL,
    referred_by uuid REFERENCES opts.accounts(id),

    name text NOT NULL,
    locale locale NOT NULL REFERENCES core.languages(code),

    is_active bool NOT NULL DEFAULT true,
    is_deleted bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE opts.accounts
  IS 'Multi-opts Accounts';

  CALL after_create_table('opts.accounts');
COMMIT;

 -- table opts.configs
 BEGIN;
   CALL watch_create_table('opts.configs');
 
   CREATE TABLE opts.configs (
     account_id uuid NOT NULL REFERENCES opts.accounts(id),
     form entity_scoped NOT NULL REFERENCES core.forms(form),
     data jsonb NOT NULL,
 
     PRIMARY KEY(account_id, form)
   );
 
   COMMENT ON TABLE opts.configs IS
   'Configuration Data for Accounts';
 
   CALL after_create_table('opts.configs');
 COMMIT;
 
-- table opts.domains
BEGIN;
  CALL watch_create_table('opts.domains');

  CREATE TABLE opts.domains (
    domain_name domain_name PRIMARY KEY,

    account_id uuid UNIQUE NOT NULL REFERENCES opts.accounts(id),

    is_verified bool NOT NULL DEFAULT false,
    is_active bool NOT NULL DEFAULT false
  );

  COMMENT ON TABLE opts.domains
  IS 'Domains that can be routed';

  CALL after_create_table('opts.domains');
COMMIT;

-- table opts.invitations
BEGIN;
  CALL watch_create_table('opts.invitations');

  CREATE TABLE opts.invitations (
    account_id uuid NOT NULL REFERENCES opts.accounts(id),
    email email NOT NULL,

    role_name entity NOT NULL REFERENCES auth.roles(role),
    opts_id uuid REFERENCES auth.users(id),

    invited_by uuid REFERENCES auth.users(id),

    UNIQUE(account_id, email)
  );

  COMMENT ON TABLE opts.invitations
  IS 'Invitations to new Users';

  CALL after_create_table('opts.invitations');
COMMIT;

-- table opts.preferences
BEGIN;
  CALL watch_create_table('opts.preferences');

  CREATE TABLE opts.preferences (
    opts_id uuid NOT NULL REFERENCES auth.users(id),
    preference entity NOT NULL REFERENCES core.preferences(preference),

    value jsonvalue NOT NULL,

    UNIQUE(opts_id, preference)
  );

  COMMENT ON TABLE opts.preferences
  IS 'Preferences set by opts';

  CALL after_create_table('opts.preferences');

  CREATE OR REPLACE TRIGGER opts_preferences_value
  BEFORE UPDATE ON opts.preferences
  FOR EACH ROW EXECUTE FUNCTION value_to_jsonvalue();
COMMIT;

-- table opts.settings
BEGIN;
  CALL watch_create_table('opts.settings');

  CREATE TABLE opts.settings (
    account_id uuid NOT NULL REFERENCES opts.accounts(id),
    setting entity NOT NULL REFERENCES core.settings(setting),
    value jsonvalue NOT NULL,

    PRIMARY KEY (account_id, setting)
  );

  COMMENT ON TABLE opts.settings
  IS 'Domains that can be routed';

  CALL after_create_table('opts.settings');

  CREATE OR REPLACE TRIGGER opts_settings_value
  BEFORE UPDATE ON opts.settings
  FOR EACH ROW EXECUTE FUNCTION value_to_jsonvalue();
COMMIT;

-- table opts.users
BEGIN;
  CALL watch_create_table('opts.users');

  CREATE TABLE opts.users (
    account_id uuid NOT NULL REFERENCES opts.accounts(id),
    opts_id uuid NOT NULL REFERENCES auth.users(id),

    role entity NOT NULL REFERENCES auth.roles(role),

    UNIQUE (account_id, opts_id)
  );

  COMMENT ON TABLE opts.users
  IS 'Users allowed to access an Account';

  CALL after_create_table('opts.users');
COMMIT;

-- function opts.accounts_settings
CREATE OR REPLACE FUNCTION opts.accounts_settings(rec opts.accounts)
RETURNS SETOF core.settings AS $$
  SELECT
    cs.setting,
    cs.feature,
    cs.datatype,
    COALESCE(os.value, cs.value) AS value,
    cs.description
  FROM core.settings cs
  LEFT OUTER JOIN opts.settings os
    ON (os.setting = cs.setting)
  WHERE os.account_id = rec.id;
$$ LANGUAGE sql STABLE;

-- function opts.accounts_referal_code
CREATE OR REPLACE FUNCTION opts.accounts_referral_code() 
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
BEFORE INSERT OR UPDATE ON opts.accounts
FOR EACH ROW
EXECUTE FUNCTION opts.accounts_referral_code();

-- function opts.accounts_translation
CREATE OR REPLACE FUNCTION opts.accounts_translation(rec opts.accounts)
RETURNS jsonb AS $$
  SELECT core.translation(rec.locale)
  FROM (VALUES (rec)) as tmp(rec);
$$ LANGUAGE sql STABLE;

-- function opts.users_translation
CREATE OR REPLACE FUNCTION opts.accounts_translation(rec auth.users)
RETURNS jsonb AS $$
  SELECT core.translation(rec.locale)
  FROM (VALUES (rec)) AS tmp(rec);
$$ LANGUAGE sql STABLE;
