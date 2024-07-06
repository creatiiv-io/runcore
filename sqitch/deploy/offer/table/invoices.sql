-- Deploy AppCore:offer/table/invoices to pg

BEGIN;

CREATE TABLE offer.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  num int GENERATED ALWAYS AS IDENTITY,

  plan_id uuid NOT NULL REFERENCES offer.plans(id),
  account_id uuid NOT NULL REFERENCES client.accounts(id),

  lines jsonb,
  amount numeric(9, 2) NOT NULL,

  is_paid bool NOT NULL DEFAULT false,

  metadata jsonb
);

COMMENT ON TABLE offer.invoices
IS 'Invoices generated for Acounts';

COMMIT;
