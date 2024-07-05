-- Deploy AppCore:core/table/columns to pg

BEGIN;

CREATE TABLE core.columns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sorting SERIAL,
  name TEXT NOT NULL,
  is_public BOOLEAN NOT NULL DEFAULT TRUE,
  is_done BOOLEAN NOT NULL DEFAULT FALSE
);

COMMIT;
