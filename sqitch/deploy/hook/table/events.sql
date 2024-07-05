-- Deploy AppCore:hook/table/events to pg

BEGIN;

CREATE TABLE hook.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  sorting SERIAL,
  name text UNIQUE NOT NULL,
  description text NOT NULL,

  is_active bool NOT NULL DEFAULT true
);

COMMENT ON TABLE hook.events
IS 'Events which can trigger webhooks';

COMMIT;
