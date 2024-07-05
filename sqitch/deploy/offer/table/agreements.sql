-- Deploy AppCore:offer/table/agreements to pg

BEGIN;

CREATE TABLE offer.agreements (
  id uuid PRIMARY KEY,
  name text NOT NULL
);

COMMENT ON TABLE offer.agreements
IS 'Contract agreement names';

COMMIT;
