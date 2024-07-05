-- Deploy AppCore:offer/table/revisions to pg

BEGIN;

CREATE TABLE offer.revisions (
  id uuid PRIMARY KEY,

  revision SERIAL,
  agreement_id uuid NOT NULL REFERENCES offer.agreements(id),

  language_code varchar(2) NOT NULL REFERENCES setup.languages(code),
  body text NOT NULL
);

COMMENT ON TABLE offer.revisions
IS 'Contract revisions possibly in different languages';

COMMIT;
