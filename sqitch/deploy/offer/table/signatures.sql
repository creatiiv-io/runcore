-- Deploy AppCore:offer/table/signatures to pg

BEGIN;

CREATE TABLE offer.signatures (
  user_id uuid NOT NULL REFERENCES auth.users(id),
  revision_id uuid NOT NULL REFERENCES offer.revisions(id),

  agreed_at timestamptz NOT NULL DEFAULT now(),

  UNIQUE(user_id, revision_id)
);

COMMENT ON TABLE offer.signatures
IS 'User Signatures for agreements';

COMMIT;
