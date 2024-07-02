-- Deploy AppCore:core/table/forms to pg

BEGIN;

CREATE TABLE core.forms (
  id uuid PRIMARY KEY,

  name text NOT NULL,
  form text NOT NULL,

  is_configuration bool NOT NULL DEFAULT false,

  data jsonb NOT NULL,

  graphql text
);

COMMENT ON TABLE core.forms
IS 'Data structures for an Application Forms';

COMMIT;
