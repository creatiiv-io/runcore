-- Deploy AppCore:core/table/agreements to pg

BEGIN;

CREATE TABLE core.agreements (
  id uuid PRIMARY KEY,
  name text NOT NULL
);

COMMENT ON TABLE core.agreements
IS 'Contract agreement names';

COMMIT;
