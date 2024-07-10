-- initialize auth user
DO $$
BEGIN
  CREATE ROLE "${RUNCORE_AUTH_USER}" WITH
    PASSWORD '${RUNCORE_AUTH_PASSWORD}'
    LOGIN
    NOINHERIT
    CREATEROLE
    NOREPLICATION;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'role "${RUNCORE_AUTH_USER}" already exists, skipping';
END $$;

-- make sure we don't add extra stuff
ALTER ROLE "${RUNCORE_AUTH_USER}" SET search_path TO auth;

-- schema auth
CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION "${RUNCORE_AUTH_USER}";

-- drop to auth user
SET ROLE "${RUNCORE_AUTH_USER}";

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA auth
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA auth TO "${RUNCORE_HASURA_USER}";

RESET ROLE;

-- this is needed in case of events
-- reference: https://hasura.io/docs/latest/deployment/postgres-requirements/
GRANT USAGE ON SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
GRANT CREATE ON SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
GRANT ALL ON ALL TABLES IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
GRANT ALL ON ALL SEQUENCES IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA hdb_catalog TO "${RUNCORE_AUTH_USER}";

-- restore search_path so citext and other extensions are available
ALTER ROLE "${RUNCORE_AUTH_USER}" SET search_path TO public;

-- table auth.migrations
BEGIN;
  CALL watch_create_table('auth.migrations');

  CREATE TABLE auth.migrations (
    id integer PRIMARY KEY,

    name varchar(100) NOT NULL UNIQUE,
    hash varchar(40) NOT NULL,

    executed_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  COMMENT ON TABLE auth.migrations
  IS 'Internal table for tracking migrations. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.migrations');

  ALTER TABLE auth.migrations
  OWNER TO "${RUNCORE_AUTH_USER}";

  INSERT INTO auth.migrations (id, name, hash)
  VALUES
    (0,'create-migrations-table','9c0c864e0ccb0f8d1c77ab0576ef9f2841ec1b68'),
    (1,'create-initial-tables','c16083c88329c867581a9c73c3f140783a1a5df4'),
    (2,'custom-user-fields','78236c9c2b50da88786bcf50099dd290f820e000'),
    (3,'discord-twitch-providers','857db1e92c7a8034e61a3d88ea672aec9b424036'),
    (4,'provider-request-options','42428265112b904903d9ad7833d8acf2812a00ed'),
    (5,'table-comments','78f76f88eff3b11ebab9be4f2469020dae017110'),
    (6,'setup-webauthn','87ba279363f8ecf8b450a681938a74b788cf536c'),
    (7,'add_authenticator_nickname','d32fd62bb7a441eea48c5434f5f3744f2e334288'),
    (8,'workos-provider','0727238a633ff119bedcbebfec6a9ea83b2bd01d'),
    (9,'rename-authenticator-to-security-key','fd7e00bef4d141a6193cf9642afd88fb6fe2b283'),
    (10,'azuread-provider','f492ff4780f8210016e1c12fa0ed83eb4278a780'),
    (11,'add_refresh_token_hash_column','62a2cd295f63153dd9f16f3159d1ab2a49b01c2f'),
    (12,'add_refresh_token_metadata','3daa907e813d1e8b72107112a89916909702897c'),
    (13,'add_refresh_token_type','0937470d919981a2052e4a00dfaad34378477765'),
    (14,'alter_refresh_token_type','e23fd094aef2ef926a06ac84000471a829548165'),
    (15,'rename_refresh_token_column','71e1d7fa6e6056fa193b4ff4d6f8e61cf3f5cd9f'),
    (16,'index_on_refresh_tokens','f129db784d60b1578ca310d9f49fc9363c257431')
  ON CONFLICT DO NOTHING;
COMMIT;

-- table auth.roles
BEGIN;
  CALL watch_create_table('auth.roles');

  CREATE TABLE auth.roles (
    role entity PRIMARY KEY
  );

  COMMENT ON TABLE auth.roles
  IS 'Persistent Hasura roles for users. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.roles');

  ALTER TABLE auth.roles
  OWNER TO "${RUNCORE_AUTH_USER}";

  INSERT INTO auth.roles (role)
  VALUES
    ('admin'),
    ('owner'),
    ('agent'),
    ('clerk'),
    ('client'),
    ('public')
  ON CONFLICT DO NOTHING;
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
    phone_number text UNIQUE,
    password_hash text,

    email_verified boolean NOT NULL DEFAULT false,
    phone_number_verified boolean NOT NULL DEFAULT false,
  
    default_role text NOT NULL DEFAULT 'client' REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT,

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

  ALTER TABLE auth.users
  OWNER TO "${RUNCORE_AUTH_USER}";

  CREATE OR REPLACE TRIGGER auth_users_updated_at
  BEFORE UPDATE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION back.updated_at();
COMMIT;

-- table auth.user_roles
BEGIN;
  CALL watch_create_table('auth.user_roles');

  CREATE TABLE auth.user_roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    role entity NOT NULL REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (user_id, role)
  );

  COMMENT ON TABLE auth.user_roles
  IS 'Roles of users. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.user_roles');

  ALTER TABLE auth.user_roles
  OWNER TO "${RUNCORE_AUTH_USER}";
COMMIT;

-- table auth.providers
BEGIN;
  CALL watch_create_table('auth.providers');

  CREATE TABLE auth.providers (
    id entity PRIMARY KEY
  );

  COMMENT ON TABLE auth.providers
  IS 'Persistent Hasura roles for users. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.providers');

  ALTER TABLE auth.providers
  OWNER TO "${RUNCORE_AUTH_USER}";

  INSERT INTO auth.providers (id)
  VALUES
    ('github'),
    ('facebook'),
    ('twitter'),
    ('google'),
    ('apple'),
    ('linkedin'),
    ('windowslive'),
    ('spotify'),
    ('strava'),
    ('gitlab'),
    ('bitbucket'),
    ('discord'),
    ('twitch'),
    ('workos'),
    ('azuread')
  ON CONFLICT DO NOTHING;
COMMIT;

-- table auth.user_providers
BEGIN;
  CALL watch_create_table('auth.user_providers');

  CREATE TABLE auth.user_providers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    provider_id entity NOT NULL REFERENCES auth.providers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    provider_user_id text NOT NULL,

    access_token text NOT NULL,
    refresh_token text,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

     UNIQUE (user_id, provider_id),
     UNIQUE (provider_id, provider_user_id)
  );

  COMMENT ON TABLE auth.user_providers
  IS 'Active providers for a given user. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.user_providers');

  ALTER TABLE auth.user_providers
  OWNER TO "${RUNCORE_AUTH_USER}";

  CREATE OR REPLACE TRIGGER auth_user_providers_updated_at
  BEFORE UPDATE ON auth.user_providers
  FOR EACH ROW EXECUTE FUNCTION back.updated_at();
COMMIT;

-- table auth.user_security_keys
BEGIN;
  CALL watch_create_table('auth.user_security_keys');

  CREATE TABLE auth.user_security_keys (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,

    credential_id text NOT NULL UNIQUE,
    credential_public_key bytea,

    counter bigint NOT NULL DEFAULT 0,
    transports character varying(255) NOT NULL DEFAULT '',

    nickname text
  );

  COMMENT ON TABLE auth.user_security_keys
  IS 'User webauthn security keys. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.user_security_keys');

  ALTER TABLE auth.user_security_keys
  OWNER TO "${RUNCORE_AUTH_USER}";
COMMIT;

-- table auth.provider_requests
BEGIN;
  CALL watch_create_table('auth.provider_requests');

  CREATE TABLE auth.provider_requests (
    id uuid PRIMARY KEY,
    options jsonb
  );

  COMMENT ON TABLE auth.provider_requests
  IS 'Oauth requests, inserted before redirecting to the provider''s site. Don''t modify its structure as Hasura Auth relies on it to function properly.';

  CALL after_create_table('auth.provider_requests');

  ALTER TABLE auth.provider_requests
  OWNER TO "${RUNCORE_AUTH_USER}";
COMMIT;

-- table auth.refresh_token_types
BEGIN;
  CALL watch_create_table('auth.refresh_token_types');

  CREATE TABLE auth.refresh_token_types (
    value entity PRIMARY KEY,
    comment text
  );

  CALL after_create_table('auth.refresh_token_types');

  ALTER TABLE auth.refresh_token_types
  OWNER TO "${RUNCORE_AUTH_USER}";

  INSERT INTO auth.refresh_token_types (value, comment)
  VALUES
    ('regular', 'Regular refresh token'),
    ('pat', 'Personal access token')
  ON CONFLICT DO NOTHING;
COMMIT;

-- table auth.refresh_tokens
BEGIN;
  CALL watch_create_table('auth.refresh_tokens');

  CREATE TABLE auth.refresh_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE,

    type entity NOT NULL DEFAULT 'regular' REFERENCES auth.refresh_token_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    refresh_token_hash character varying(255),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '4 months'
  );

  CREATE INDEX refresh_tokens_hash_expires_at_user_id_idx
  ON auth.refresh_tokens
  USING btree (refresh_token_hash, expires_at, user_id);

  CALL after_create_table('auth.refresh_tokens');

  ALTER TABLE auth.refresh_tokens
  OWNER TO "${RUNCORE_AUTH_USER}";
COMMIT;

