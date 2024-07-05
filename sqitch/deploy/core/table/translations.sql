-- Deploy AppCore:core/table/translations to pg

BEGIN;

CREATE TABLE core.translations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  language text NOT NULL REFERENCES core.languages(language),
  thing text NOT NULL,
  name text NOT NULL,
  description text NOT NULL
);


COMMIT;
