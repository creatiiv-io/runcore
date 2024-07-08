-- setup schema
CREATE SCHEMA IF NOT EXISTS setup;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA setup
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA setup TO "${RUNCORE_HASURA_USER}";

-- setup.languages
BEGIN;
  CALL watch_create_table('setup.languages');

  CREATE TABLE setup.languages (
    code varchar(2) PRIMARY KEY,
    name text NOT NULL
  );

  COMMENT ON TABLE setup.languages
  IS 'Language selection for internationalization support';

  CALL after_create_table('setup.languages');

  INSERT INTO setup.languages
  VALUES ('en', 'English')
  ON CONFLICT DO NOTHING;
COMMIT;

-- setup.translations
BEGIN;
  CALL watch_create_table('setup.translations');

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

  CALL after_create_table('setup.translations');
COMMIT;

-- setup.features
BEGIN;
  CALL watch_create_table('setup.features');

  CREATE TABLE setup.features (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    sorting SERIAL,
    name text UNIQUE NOT NULL,
    description text NOT NULL,

    amount smallint NOT NULL
  );

  COMMENT ON TABLE setup.features IS
  'Feaatures that a plan may Include';

  CALL after_create_table('setup.features');
COMMIT;

-- setup.settings
BEGIN;
  CALL watch_create_table('setup.settings');

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

  CALL after_create_table('setup.settings');
COMMIT;

-- setup.forms
BEGIN;
  CALL watch_create_table('setup.forms');

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

  CALL after_create_table('setup.forms');
COMMIT;

-- setup.preferences
BEGIN;
  CALL watch_create_table('setup.preferences');

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

  CALL after_create_table('setup.preferences');
COMMIT;
