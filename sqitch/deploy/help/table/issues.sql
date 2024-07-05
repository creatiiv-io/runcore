-- Deploy AppCore:core/table/issues to pg

BEGIN;

CREATE TABLE core.issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  num SERIAL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  reply_to UUID REFERENCES core.issues(id),
  column_id UUID REFERENCES core.columns(id)
);

COMMIT;
