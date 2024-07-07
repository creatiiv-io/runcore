-- setup schema
CREATE SCHEMA IF NOT EXISTS setup;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA setup
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA setup TO "${RUNCORE_HASURA_USER}";

-- setup.languages
BEGIN;
  CALL create_pre_migration('setup.languages');

  CREATE TABLE setup.languages (
    code varchar(2) PRIMARY KEY,
    name text NOT NULL
  );

  COMMENT ON TABLE setup.languages
  IS 'Language selection for internationalization support';

  INSERT INTO setup.languages
  VALUES ('en', 'English');

  CALL create_post_migration('setup.languages');
COMMIT;

-- setup.translations
BEGIN;
  CALL create_pre_migration('setup.translations');

  CREATE TABLE setup.translations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    category text NOT NULL,
    language_code varchar(2) NOT NULL REFERENCES setup.languages(code),

    thing text NOT NULL,
    name text NOT NULL,
    description text NOT NULL
  );

  COMMENT ON TABLE setup.languages
  IS 'Translations of things for internationalization support';

  CALL create_post_migration('setup.translations');
COMMIT;

-- setup.features
BEGIN;
  CALL create_pre_migration('setup.features');

  CREATE TABLE setup.features (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    sorting SERIAL,
    name text UNIQUE NOT NULL,
    description text NOT NULL,

    amount smallint NOT NULL
  );

  COMMENT ON TABLE setup.features IS
  'Feaatures that a plan may Include';

  CALL create_post_migration('setup.forms');
COMMIT;

-- setup.settings
BEGIN;
  CALL create_pre_migration('setup.settings');

  CREATE TABLE setup.settings (
    id uuid PRIMARY KEY DEFAULT (gen_random_uuid()),

    sorting SERIAL,
    category text,
    name text NOT NULL,
    description text NOT NULL,

    feature_id uuid REFERENCES setup.features(id),

    datatype text NOT NULL CHECK (datatype IN ('number','string','boolean')),
    value jsonb NOT NULL
  );

  COMMENT ON TABLE setup.settings
  IS 'Settings with sorting';

  CALL create_post_migration('setup.settings');
COMMIT;

-- setup.forms
BEGIN;
  CALL create_pre_migration('setup.forms');

  CREATE TABLE setup.forms (
    id uuid PRIMARY KEY,

    name text NOT NULL,
    form text NOT NULL,

    is_configuration bool NOT NULL DEFAULT false,

    data jsonb NOT NULL,

    graphql text
  );

  COMMENT ON TABLE setup.forms
  IS 'Data structures for an Application Forms';

  CALL create_post_migration('setup.forms');
COMMIT;

-- setup.preferences
BEGIN;
  CALL create_pre_migration('setup.preferences');

  CREATE TABLE setup.preferences (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    sorting SERIAL,
    category text,
    name text NOT NULL,
    description text NOT NULL,

    feature_id uuid REFERENCES setup.features(id),

    datatype text NOT NULL,
    value jsonb NOT NULL
  );

  COMMENT ON TABLE setup.preferences
  IS 'User Preferences with sorting';

  CALL create_post_migration('setup.preferences');
COMMIT;
