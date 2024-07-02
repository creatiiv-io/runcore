-- Deploy AppCore:core/table/events to pg

BEGIN;

CREATE TABLE core.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  name text UNIQUE NOT NULL,
  description text NOT NULL,

  is_active bool NOT NULL DEFAULT true
);

COMMENT ON TABLE core.events
IS 'Events which can trigger webhooks';

COMMIT;
