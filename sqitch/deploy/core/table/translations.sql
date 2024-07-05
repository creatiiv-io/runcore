-- Deploy AppCore:core/table/translations to pg

BEGIN;

CREATE TABLE core.translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  language_code varchar(2) NOT NULL REFERENCES core.languages(code),
  thing text NOT NULL,
  name text NOT NULL,
  description text NOT NULL
);

COMMENT ON TABLE core.languages
IS 'Translations of things for internationalization support';

COMMIT;
