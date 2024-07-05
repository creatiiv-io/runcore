-- Deploy AppCore:core/table/signatures to pg

BEGIN;

CREATE TABLE core.signatures (
  user_id uuid NOT NULL REFERENCES auth.users(id),
  revision_id uuid NOT NULL REFERENCES core.revisions(id),

  agreed_at timestamptz NOT NULL DEFAULT now(),

  UNIQUE(user_id, revision_id)
);

COMMENT ON TABLE core.signatures
IS 'User Signatures for agreements';

COMMIT;
