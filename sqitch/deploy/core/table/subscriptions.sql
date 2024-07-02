-- Deploy AppCore:core/table/subscriptions to pg

BEGIN;

CREATE TABLE core.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id uuid NOT NULL REFERENCES core.accounts(id),
  plan_id uuid NOT NULL REFERENCES core.plans(id),

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

COMMENT ON TABLE core.subscriptions
IS 'Subscriptions to Plans from Accounts';

COMMIT;
