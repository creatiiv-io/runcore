-- Deploy AppCore:setup/table/forms to pg

BEGIN;

CREATE TABLE setup.forms (
  id uuid PRIMARY KEY,

  name text NOT NULL,
  form text NOT NULL,

  is_configuration bool NOT NULL DEFAULT false,

  data jsonb NOT NULL,

  graphql text
);

COMMENT ON TABLE setup.forms
IS 'Data structures for an Application Forms';

COMMIT;
