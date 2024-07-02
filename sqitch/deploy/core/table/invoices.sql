-- Deploy AppCore:core/table/invoices to pg

BEGIN;

CREATE TABLE core.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  plan_id uuid NOT NULL REFERENCES core.plans (id),
  account_id uuid NOT NULL REFERENCES core.accounts (id),

  lines jsonb,
  amount numeric(9, 2) NOT NULL,

  is_paid bool NOT NULL DEFAULT false,

  metadata jsonb
);

COMMENT ON TABLE core.invoices
IS 'Invoices generated for Acounts';

COMMIT;
