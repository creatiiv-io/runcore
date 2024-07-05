-- Deploy AppCore:setup/table/translations to pg

BEGIN;

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

COMMIT;
