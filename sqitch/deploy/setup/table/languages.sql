-- Deploy AppCore:setup/table/languages to pg

BEGIN;

CREATE TABLE setup.languages (
  code varchar(2) PRIMARY KEY,
  name text NOT NULL
);

COMMENT ON TABLE setup.languages
IS 'Language selection for internationalization support';

INSERT INTO setup.languages
VALUES ('en', 'English');

COMMIT;
