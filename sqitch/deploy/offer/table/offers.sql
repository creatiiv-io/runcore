-- Deploy AppCore:offer/table/plans to pg

BEGIN;

CREATE TABLE offer.plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  name text UNIQUE NOT NULL,
  extends_plan_id uuid REFERENCES offer.plans(id),

  platform text,
  number_of_codes smallint NOT NULL DEFAULT 0,

  weekly_price numeric(8,2) NOT NULL,
  monthly_price numeric(8,2) NOT NULL,
  quarterly_price numeric(9,2) NOT NULL,
  yearly_price numeric(10,2) NOT NULL,

  users_per_account smallint NOT NULL DEFAULT 1,

  is_active bool NOT NULL DEFAULT true,
  is_hidden bool NOT NULL DEFAULT true
);

COMMENT ON TABLE offer.plans
IS 'Plans to which Account may Subscribe';

COMMIT;
