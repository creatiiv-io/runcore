-- Deploy AppCore:core/table/revisions to pg

BEGIN;

CREATE TABLE core.revisions (
  id uuid PRIMARY KEY,

  revision SERIAL,
  agreement_id uuid NOT NULL REFERENCES core.agreements(id),

  language_code varchar(2) NOT NULL REFERENCES core.languages(code),
  body text NOT NULL
);

COMMENT ON TABLE core.revisions
IS 'Contract revisions possibly in different languages';

COMMIT;
