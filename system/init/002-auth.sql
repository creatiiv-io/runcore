-- schema auth
CREATE SCHEMA IF NOT EXISTS auth;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA auth
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA auth TO "${RUNCORE_HASURA_USER}";

-- table auth.roles
BEGIN;
  CALL watch_create_table('auth.roles');

  CREATE TABLE auth.roles (
    role entity PRIMARY KEY,
    type text NOT NULL DEFAULT 'external',
    description text
  );

  COMMENT ON TABLE auth.roles
  IS 'Persistent Hasura roles for users.';

  --CALL after_create_table('auth.roles');
COMMIT;

-- table auth.users
BEGIN;
  CALL watch_create_table('auth.users');

  CREATE TABLE auth.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    display_name text NOT NULL DEFAULT '',
    avatar_url text NOT NULL DEFAULT '',
    locale locale NOT NULL,

    email email UNIQUE,
    phone_number phone UNIQUE,
    password_hash text,

    email_verified boolean NOT NULL DEFAULT false,
    phone_number_verified boolean NOT NULL DEFAULT false,
  
    default_role entity NOT NULL DEFAULT '${RUNCORE_HASURA_DEFAULTROLE}' REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT,

    is_anonymous boolean NOT NULL DEFAULT false,
    disabled boolean NOT NULL DEFAULT false,
    last_seen timestamptz,

    otp_method_last_used text,
    otp_hash text,
    otp_hash_expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    totp_secret text,
    active_mfa_type text,

    ticket text,
    ticket_expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    metadata jsonb,
    new_email email,

    webauthn_current_challenge text,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
    CONSTRAINT active_mfa_types_check CHECK (((active_mfa_type = 'totp'::text) OR (active_mfa_type = 'sms'::text)))
  );

  COMMENT ON TABLE auth.users
  IS 'User account information. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.users');

  CREATE OR REPLACE TRIGGER auth_users_updated_at
  BEFORE UPDATE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION back.updated_at();
COMMIT;

-- table auth.permissions
BEGIN;
  CALL watch_create_table('auth.permissions');

  CREATE TABLE auth.permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    role_name entity NOT NULL REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  COMMENT ON TABLE auth.permissions
  IS 'Assigned permissions for a user.';

  CALL after_create_table('auth.permissions');
COMMIT;

-- table auth.verifications
BEGIN;
  CALL watch_create_table('auth.verifications');

  CREATE TABLE auth.verifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,

    redirect_url TEXT DEFAULT '/',
    token TEXT GENERATED ALWAYS AS (
      replace(id::text, '-', '')
    ) STORED,

    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    verified_at timestamptz
  );

  COMMENT ON TABLE auth.verifications
  IS 'Stored verification chanlenges.';

  CALL after_create_table('auth.verifications');
COMMIT;

-- table auth.verify_redirect(text)
CREATE OR REPLACE FUNCTION auth.verify_redirect(token text)
RETURNS TEXT AS $$
WITH updated AS (
  UPDATE auth.verifications
    SET verified_at = current_timestamp
  WHERE token = token
    AND verified_at IS NULL
  RETURNING redirect_url
)
SELECT redirect_url FROM updated;
$$ LANGUAGE sql VOLATILE;

-- table auth.keys
BEGIN;
  CALL watch_create_table('auth.keys');

  CREATE TABLE auth.keys (
    sshkey TEXT NOT NULL,
    nickname TEXT NOT NULL
  ) INHERITS (auth.verifications);

  COMMENT ON TABLE auth.keys
  IS 'User ssh keys.';

  CALL after_create_table('auth.keys');
COMMIT;

-- function auth.keys_user_id()
CREATE OR REPLACE FUNCTION auth.keys_user_id()
RETURNS TRIGGER AS $$
DECLARE
  email text;
  user_id uuid;
BEGIN
  -- Extract the email from the SSH key
  email := split_part(NEW.key, ' ', 2);

  -- Look up the user_id based on the email
  SELECT au.id
  INTO user_id
  FROM auth.users au
  WHERE au.email = email;

  -- Check if the user_id was found
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'No user found with email %', email;
  END IF;

  -- Set the user_id in the NEW row
  NEW.user_id := user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE OR REPLACE TRIGGER auth_keys_set_user_id
BEFORE INSERT ON auth.keys
FOR EACH ROW
EXECUTE FUNCTION auth.keys_user_id();

-- table auth.tokens
BEGIN;
  CALL watch_create_table('auth.tokens');

  CREATE TABLE auth.tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,

    type entity NOT NULL DEFAULT 'refresh',
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    token_hash character varying(255),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '4 months'
  );

  CALL after_create_table('auth.tokens');
COMMIT;

-- table auth.settings
BEGIN;
  CALL watch_create_table('auth.settings');

  CREATE TABLE auth.settings (
    setting entity_scoped PRIMARY KEY,
    datatype datatype GENERATED ALWAYS AS (
      jsonb_typeof(value)
    ) STORED,
    value jsonvalue NOT NULL
  );

  CALL after_create_table('auth.settings');

  INSERT INTO auth.settings(setting, value)
  VALUES
    ('hasura.jwtsecret','"${RUNCORE_HASURA_JWTSECRET}"'),
    ('login.annonymous','${RUNCORE_LOGIN_ANNONYMOUS}'),
    ('login.defaultlanguage','"${RUNCORE_LOGIN_DEFAULTLANGUAGE}"'),
    ('login.defaultrole','"${RUNCORE_LOGIN_DEFAULTROLE}"'),
    ('login.emailpassword','${RUNCORE_LOGIN_EMAILPASSWORD}'),
    ('login.mfaenabled','${RUNCORE_LOGIN_MFAENABLED}'),
    ('login.mfamethods','"${RUNCORE_LOGIN_MFAMETHODS}"'),
    ('login.passwordexpires','${RUNCORE_LOGIN_PASSWORDEXPIRES}'),
    ('login.passwordlength','${RUNCORE_LOGIN_PASSWORDLENGTH}'),
    ('login.publicrole','"${RUNCORE_LOGIN_PUBLICROLE}"'),
    ('login.sendmagiclink','${RUNCORE_LOGIN_SENDMAGICLINK}'),
    ('login.tokenexpires','${RUNCORE_LOGIN_TOKENEXPIRES}'),
    ('login.verifycall','${RUNCORE_LOGIN_VERIFYCALL}'),
    ('login.verifyemail','${RUNCORE_LOGIN_VERIFYEMAIL}'),
    ('login.verifytext','${RUNCORE_LOGIN_VERIFYTEXT}'),
    ('login.viralrequired','${RUNCORE_LOGIN_VIRALREQUIRED}'),
    ('login.viralshares','${RUNCORE_LOGIN_VIRALSHARES}')
  ON CONFLICT DO NOTHING;
COMMIT;

-- function auth.setting
CREATE OR REPLACE FUNCTION auth.setting(name entity_scoped)
RETURNS text AS $$
  SELECT s.value #>> '{}'
  FROM auth.settings s
  WHERE s.setting = name;
$$ LANGUAGE sql IMMUTABLE;

-- function auth.encode
CREATE OR REPLACE FUNCTION auth.encode(data bytea)
RETURNS text AS $$
  SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$ LANGUAGE sql IMMUTABLE;

-- function auth.decode
CREATE OR REPLACE FUNCTION auth.decode(data text)
RETURNS bytea AS $$
  SELECT decode(
    translate(data, '-_', '+/') || 
    repeat('=', (4 - length(translate(data, '-_', '+/')) % 4) % 4), 
    'base64'
  );
$$ LANGUAGE sql IMMUTABLE;

-- function auth.hmac_sign
CREATE OR REPLACE FUNCTION auth.hmac_sign(
  input text,
  secret text,
  algorithm text
) RETURNS text AS $$
  SELECT auth.encode(
    hmac(
      input, 
      secret, 
      CASE algorithm
        WHEN 'HS256' THEN 'sha256'
        WHEN 'HS384' THEN 'sha384'
        WHEN 'HS512' THEN 'sha512'
        ELSE NULL  -- thrown for unsupported algorithms
      END
    )
  );
$$ LANGUAGE sql IMMUTABLE;

-- function auth.sign_jwt
CREATE OR REPLACE FUNCTION auth.sign_jwt(
  payload json,
  secret text,
  algorithm text DEFAULT 'HS256'
) RETURNS jwt AS $$
  SELECT
    data || '.' || auth.hmac_sign(data, secret, algorithm)
  FROM (
    SELECT
      auth.encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8'))
      || '.' ||
      auth.encode(convert_to(payload::text, 'utf8')) AS data
  ) AS token;
$$ LANGUAGE sql IMMUTABLE;

-- function auth.verify_jwt
CREATE OR REPLACE FUNCTION auth.verify_jwt(
  jwt jwt,
  secret text,
  algorithm text DEFAULT 'HS256'
) RETURNS TABLE(header json, payload json, valid boolean) AS $$
  SELECT
    tk.header,
    tk.payload,
    tk.signature_ok AND tstzrange(
      to_timestamp(nullif(regexp_replace(tk.payload->>'nbf', '^.*[^0-9.].*$', '', 'g'), '')::double precision),
      to_timestamp(nullif(regexp_replace(tk.payload->>'exp', '^.*[^0-9.].*$', '', 'g'), '')::double precision)
    ) @> CURRENT_TIMESTAMP AS valid
  FROM (
    SELECT
      convert_from(auth.decode(r[1]), 'utf8')::json AS header,
      convert_from(auth.decode(r[2]), 'utf8')::json AS payload,
      r[3] = auth.hmac_sign(r[1] || '.' || r[2], secret, algorithm) AS signature_ok
    FROM string_to_array(jwt, '.') r
  ) tk
$$ LANGUAGE sql IMMUTABLE;

-- function auth.hasura_jwt
CREATE OR REPLACE FUNCTION auth.hasura_jwt(
  user_id uuid
) RETURNS jwt AS $$
  SELECT
    auth.sign_jwt(
      json_build_object(
        'sub', au.id::text,
        'iss', 'Hasura-JWT-Auth',
        'iat', round(extract(EPOCH FROM NOW())),
        'exp', round(extract(EPOCH FROM NOW() + INTERVAL '24 hour')),
        'https://hasura.io/jwt/claims', json_build_object(
          'x-hasura-user-id', au.id,
          'x-hasura-default-role', au.default_role,
          'x-hasura-allowed-roles', json_agg(ap.role_name)
        )
      ),
      auth.setting('hasura.jwtsecret')
    ) AS jwt
  FROM auth.users au
  JOIN auth.permissions ap
    ON (ap.user_id = au.id)
  WHERE au.id = user_id
  GROUP BY au.id, ap.role_name;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- function auth.hasura_chk
CREATE OR REPLACE FUNCTION auth.hasura_chk(
  user_id uuid,
  jwt jwt
) RETURNS boolean AS $$
  SELECT
    av.valid AND av.payload->>'sub' = au.id::text
  FROM auth.verify_jwt(
    jwt,
    auth.setting('hasura.jwtsecret')
  ) AS av
  LEFT JOIN auth.users AS au
    ON au.id = user_id;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- function auth.setup(email, password)
CREATE OR REPLACE FUNCTION auth.setup(
  email email,
  password password
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.setup(phone, password)
CREATE OR REPLACE FUNCTION auth.setup(
  phone phone,
  password password
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.login(email, password)
CREATE OR REPLACE FUNCTION auth.login(
  email email,
  password password
) RETURNS jwt AS $$
  SELECT '0.0.0'::jwt;
$$ LANGUAGE sql VOLATILE;

-- function auth.login(phone, password)
CREATE OR REPLACE FUNCTION auth.login(
  phone phone,
  password password
) RETURNS jwt AS $$
  SELECT '0.0.0'::jwt;
$$ LANGUAGE sql VOLATILE;

-- function auth.login()
CREATE OR REPLACE FUNCTION auth.login(
) RETURNS jwt AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.magic(email)
CREATE OR REPLACE FUNCTION auth.magic(
  email email
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.magic(phone)
CREATE OR REPLACE FUNCTION auth.magic(
  phone phone
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.token(token)
CREATE OR REPLACE FUNCTION auth.token(
  token jwt
) RETURNS jwt AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.change(user_id, email)
CREATE OR REPLACE FUNCTION auth.change(
  user_id uuid,
  email email
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.change(user_id, phone)
CREATE OR REPLACE FUNCTION auth.change(
  user_id uuid,
  phone phone
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

-- function auth.change(user_id, password)
CREATE OR REPLACE FUNCTION auth.change(
  user_id uuid,
  password password
) RETURNS boolean AS $$
  SELECT true;
$$ LANGUAGE sql VOLATILE;

REVOKE ALL ON TABLE auth.settings FROM PUBLIC;
REVOKE ALL ON TABLE auth.settings FROM "${RUNCORE_HASURA_USER}";
REVOKE ALL ON FUNCTION auth.setting FROM PUBLIC;
REVOKE ALL ON FUNCTION auth.setting FROM "${RUNCORE_HASURA_USER}";
