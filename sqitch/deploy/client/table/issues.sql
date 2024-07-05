-- Deploy AppCore:client/table/issues to pg

BEGIN;

CREATE TABLE client.issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  num SERIAL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  reply_to UUID REFERENCES client.issues(id),
  column_id UUID REFERENCES setup.columns(id)
);

COMMIT;