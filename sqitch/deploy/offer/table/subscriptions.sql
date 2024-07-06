-- Deploy AppCore:offer/table/subscriptions to pg

BEGIN;

CREATE TABLE offer.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id uuid NOT NULL REFERENCES client.accounts(id),
  plan_id uuid NOT NULL REFERENCES offer.plans(id),

  quantity smallint NOT NULL DEFAULT 1,
  price numeric(10,2) NOT NULL,
  cycle text NOT NULL CHECK(cycle IN('weekly','monthly','quarterly','yearly')),

  metadata jsonb,

  is_active bool NOT NULL DEFAULT true,
  activated_at timestamptz NOT NULL DEFAULT now(),

  is_paused bool NOT NULL DEFAULT false,
  billed_at timestamptz NOT NULL DEFAULT now(),

  expires_at timestamptz NOT NULL
);

COMMENT ON TABLE offer.subscriptions
IS 'Subscriptions to Plans from Accounts';

COMMIT;
