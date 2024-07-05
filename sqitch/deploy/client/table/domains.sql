-- Deploy AppCore:client/table/domains to pg

BEGIN;

CREATE TABLE client.domains (
  domain_name text PRIMARY KEY,

  account_id uuid UNIQUE NOT NULL REFERENCES client.accounts(id),

  is_verified bool NOT NULL DEFAULT false,
  is_active bool NOT NULL DEFAULT false
);

COMMENT ON TABLE client.domains
IS 'Domains that can be routed';

COMMIT;
