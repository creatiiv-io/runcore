-- Deploy AppCore:core/table/languages to pg

BEGIN;

CREATE TABLE core.languages (
  code varchar(2) PRIMARY KEY,
  name text NOT NULL
);

COMMENT ON TABLE core.languages
IS 'Language selection for internationalization support';

INSERT INTO core.languages
VALUES ('en', 'English');

COMMIT;
