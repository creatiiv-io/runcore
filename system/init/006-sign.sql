-- sign schema
CREATE SCHEMA IF NOT EXISTS sign;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA sign
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA sign TO "${RUNCORE_HASURA_USER}";


-- sign.agreements
BEGIN;
  CALL watch_create_table('sign.agreements');

  CREATE TABLE sign.agreements (
    agreement entity PRIMARY KEY
  );

  COMMENT ON TABLE sign.agreements
  IS 'Contract agreement names';

  CALL after_create_table('sign.agreements');
COMMIT;

-- sign.requirements
BEGIN;
  CALL watch_create_table('sign.requirements');

  CREATE TABLE sign.requirements (
    feature entity_scoped NOT NULL REFERENCES core.features(feature),
    agreement entity NOT NULL REFERENCES sign.agreements(agreement),
    description text,

    PRIMARY KEY (feature, agreement)
  );

  COMMENT ON TABLE sign.requirements
  IS 'Requirement that features need agreement';

  CALL after_create_table('sign.requirements');
COMMIT;

-- sign.revisions
BEGIN;
  CALL watch_create_table('sign.revisions');

  CREATE TABLE sign.revisions (
    id uuid PRIMARY KEY,
    revision SERIAL,
    timestamp timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    agreement entity NOT NULL REFERENCES sign.agreements(agreement),
    language_code locale NOT NULL REFERENCES core.languages(code),
    body text NOT NULL,

    md5 text GENERATED ALWAYS AS (
      md5(body)
    ) STORED
  );

  COMMENT ON TABLE sign.revisions
  IS 'Contract revisions possibly in different languages';

  CALL after_create_table('sign.revisions');
COMMIT;

-- sign.signatures
BEGIN;
  CALL watch_create_table('sign.signatures');

  CREATE TABLE sign.signatures (
    user_id uuid NOT NULL REFERENCES auth.users(id),
    revision_id uuid NOT NULL REFERENCES sign.revisions(id),

    agreed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, revision_id)
  );

  COMMENT ON TABLE sign.signatures
  IS 'User Signatures for agreements';

  CALL after_create_table('sign.signatures');
COMMIT;
