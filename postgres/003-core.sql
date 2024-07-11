-- core schema
CREATE SCHEMA IF NOT EXISTS core;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA core
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA core TO "${RUNCORE_HASURA_USER}";

-- table core.features
BEGIN;
  CALL watch_create_table('core.features');

  CREATE TABLE core.features (
    feature entity_scoped PRIMARY KEY,
    category entity GENERATED ALWAYS AS (
      CASE
        WHEN position('.' IN feature) = 0 THEN NULL
        ELSE split_part(feature, '.', 1)
      END
    ) STORED,
    quantity int GENERATED ALWAYS AS (1) STORED,
    description text
  );

  COMMENT ON TABLE core.features IS
  'Features that can switch features on and off';

  CALL after_create_table('core.features');
COMMIT;

-- table core.settings
BEGIN;
  CALL watch_create_table('core.settings');

  CREATE TABLE core.settings (
    setting entity PRIMARY KEY,
    feature entity_scoped REFERENCES core.features(feature),
    datatype datatype NOT NULL,
    value jsonvalue NOT NULL CHECK (jsonb_typeof(value) = datatype),
    description text NOT NULL
  );

  COMMENT ON TABLE core.settings
  IS 'Settings with sorting';

  CALL after_create_table('core.settings');
COMMIT;

-- table core.preferences
BEGIN;
  CALL watch_create_table('core.preferences');

  CREATE TABLE core.preferences (
    preference entity PRIMARY KEY,
    feature entity_scoped REFERENCES core.features(feature),
    datatype datatype NOT NULL,
    value jsonvalue NOT NULL CHECK (jsonb_typeof(value) = datatype),
    description text NOT NULL,

    sorting SERIAL
  );

  COMMENT ON TABLE core.preferences
  IS 'User Preferences with sorting';

  CALL after_create_table('core.preferences');
COMMIT;

-- table core.languages
BEGIN;
  CALL watch_create_table('core.languages');

  CREATE TABLE core.languages (
    code locale PRIMARY KEY,
    name text NOT NULL
  );

  COMMENT ON TABLE core.languages
  IS 'Language selection for internationalization support';

  CALL after_create_table('core.languages');

  INSERT INTO core.languages
  VALUES ('en', 'English')
  ON CONFLICT DO NOTHING;
COMMIT;

-- table core.translations
BEGIN;
  CALL watch_create_table('core.translations');

  CREATE TABLE core.translations (
    language locale NOT NULL REFERENCES core.languages(code),
    identifier entity_scoped NOT NULL CHECK (position('.' IN identifier) != 0),
    category entity GENERATED ALWAYS AS (
      split_part(identifier, '.', 1)
    ) STORED,
    thing entity GENERATED ALWAYS AS (
      split_part(identifier, '.', 2)
    ) STORED,
    translation text NOT NULL,
    description text,

    PRIMARY KEY (language, identifier)
  );

  COMMENT ON TABLE core.translations
  IS 'Language selection for internationalization support';

  CALL after_create_table('core.translations');

  INSERT INTO core.languages
  VALUES ('en', 'English')
  ON CONFLICT DO NOTHING;
COMMIT;

-- table core.forms
BEGIN;
  CALL watch_create_table('core.forms');

  CREATE TABLE core.forms (
    form entity_scoped PRIMARY KEY,
    html text NOT NULL,
    graphql text,

    is_configuration bool GENERATED ALWAYS AS (
      split_part(form, '.', 1) = 'config'
    ) STORED
  );

  COMMENT ON TABLE core.forms
  IS 'Data structures for an Application Forms';

  CALL after_create_table('core.forms');
COMMIT;

--- function core.translation
CREATE OR REPLACE FUNCTION core.translation(language locale)
RETURNS jsonb AS $$
WITH inner_agg AS (
  SELECT
    category,
    jsonb_object_agg(
      ct.thing,
      jsonb_build_array(
        ct.translation,
        ct.description
      )
    ) AS category_data
  FROM core.translations ct
  WHERE ct.language = language
  GROUP BY category
)
SELECT jsonb_object_agg(category, category_data)
FROM inner_agg;
$$ LANGUAGE sql;
