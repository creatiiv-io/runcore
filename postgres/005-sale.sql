-- sale schema
CREATE SCHEMA IF NOT EXISTS sale;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA sale
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA sale TO "${RUNCORE_HASURA_USER}";

-- sale.platforms
BEGIN;
  CALL watch_create_table('sale.platforms');

  CREATE TABLE sale.platform (
    platform entity PRIMARY KEY,
    description text
  );

  COMMENT ON TABLE sale.platform IS
  'Marketing platforms that can generate codes and have free stuff';

  CALL after_create_table('sale.codes');
COMMIT;

-- sale.plans
BEGIN;
  CALL watch_create_table('sale.plans');

  CREATE TABLE sale.plans (
    plan entity_scoped PRIMARY KEY,
    users smallint NOT NULL DEFAULT 1,
    monthly numeric(8,2) NOT NULL,
    yearly numeric(10,2) NOT NULL,
    platform entity REFERENCES sale.platforms(platform),
    codes smallint NOT NULL DEFAULT 0,
    description text,
    extends_plan entity GENERATED ALWAYS AS (
      CASE
        WHEN position('.' IN plan) = 0 THEN NULL
        ELSE split_part(plan, '.', 1)
      END
    ) STORED REFERENCES sale.plans(plan),
    is_hidden bool NOT NULL GENERATED ALWAYS AS (
      platform IS NOT NULL
    ) STORED,
    is_active bool NOT NULL GENERATED ALWAYS AS (
      monthly > 0 OR yearly > 0 OR platform IS NOT NULL
    ) STORED
  );

  COMMENT ON TABLE sale.plans
  IS 'Plans to which Account may Subscribe';

  CALL after_create_table('sale.plans');
COMMIT;

-- sale.features
BEGIN;
  CALL watch_create_table('sale.features');

  CREATE TABLE sale.features (
    feature text NOT NULL REFERENCES core.feature(feature),
    plan text entity_scoped NULL REFERENCES sale.plans(name),
    quantity smallint NOT NULL,
    description text

    PRIMARY KEY (plan, feature)
  );

  COMMENT ON TABLE sale.features
  IS 'Assignment of Features to a Plan by Ammount';

  CALL after_create_table('sale.features');
COMMIT;

-- sale.discounts
BEGIN;
  CALL watch_create_table('sale.discounts');

  CREATE TABLE sale.discounts (
    code entity PRIMARY KEY,
    discount numeric(2,2) NOT NULL,
    description text,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '4 months'
  );

  COMMENT ON TABLE sale.discounts IS
  'Activation codes for marketing platform';

  CALL after_create_table('sale.discounts');
COMMIT;

-- sale.codes
BEGIN;
  CALL watch_create_table('sale.codes');

  CREATE TABLE sale.codes (
    code uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    platform entity NOT NULL REFERENCES sale.platforms(platform),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '4 months'
  );

  COMMENT ON TABLE sale.codes IS
  'Activation codes for marketing platform';

  CALL after_create_table('sale.codes');
COMMIT;

-- sales.activations
BEGIN;
  CALL watch_create_table('sale.activations');

  CREATE TABLE sale.activations (
    code uuid PRIMARY KEY REFERENCES sale.codes(code),
    account_id uuid NOT NULL REFERENCES client.accounts(id),

    activated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  COMMENT ON TABLE sale.activations
  IS 'User Preferences with sorting';

  CALL after_create_table('sale.activations');
COMMIT;

-- sale.subscriptions
BEGIN;
  CALL watch_create_table('sale.subscriptions');

  CREATE TABLE sale.subscriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    plan entity_scoped NOT NULL REFERENCES sale.plans(plan),

    quantity smallint NOT NULL DEFAULT 1,
    price numeric(9,2) NOT NULL,
    discount numeric(2,2) NOT NULL DEFAULT 0,
    total numeric(10,2) GENERATED ALWAYS AS(
      quantity * price * (1 - (discount * .01)) 
    ) STORED,

    metadata jsonb,

    is_active bool NOT NULL DEFAULT true,
    activated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    is_paused bool NOT NULL DEFAULT false,
    billed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    expires_at timestamptz NOT NULL
  );

  COMMENT ON TABLE sale.subscriptions
  IS 'Subscriptions to Plans from Accounts';

  CALL after_create_table('sale.subscriptions');
COMMIT;

-- sale.invoices
BEGIN;
  CALL watch_create_table('sale.invoices');

  CREATE TABLE sale.invoices (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    num int GENERATED ALWAYS AS IDENTITY,

    plan entity_scoped NOT NULL REFERENCES sale.plans(plan),
    account_id uuid NOT NULL REFERENCES client.accounts(id),

    lines jsonb,
    amount numeric(9, 2) NOT NULL,

    is_paid bool NOT NULL DEFAULT false,

    metadata jsonb
  );

  COMMENT ON TABLE sale.invoices
  IS 'Invoices generated for Acounts';

  CALL after_create_table('sale.invoices');
COMMIT;
