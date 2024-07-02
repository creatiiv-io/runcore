-- Deploy AppCore:core/table/languages to pg

BEGIN;

CREATE TABLE core.languages (
  language text PRIMARY KEY
);

COMMENT ON TABLE core.languages
IS 'Language selection for internationalization support';

INSERT INTO core.languages
VALUES ('en');

COMMIT;
