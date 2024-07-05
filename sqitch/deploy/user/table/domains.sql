-- Deploy AppCore:core/table/domains to pg

BEGIN;

CREATE TABLE core.domains (
  domain_name text PRIMARY KEY,

  account_id uuid UNIQUE NOT NULL REFERENCES core.accounts(id),

  is_verified bool NOT NULL DEFAULT false,
  is_active bool NOT NULL DEFAULT false
);

COMMENT ON TABLE core.domains
IS 'Domains that can be routed';

COMMIT;
