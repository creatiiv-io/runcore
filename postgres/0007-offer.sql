-- offer schema
CREATE SCHEMA IF NOT EXISTS offer;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA offer
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA offer TO "${RUNCORE_HASURA_USER}";

-- offer.codes
BEGIN;
  CALL watch_create_table('offer.codes');

  CREATE TABLE offer.codes (
    code_num uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    platform text NOT NULL,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP + INTERVAL '4 months'
  );

  COMMENT ON TABLE offer.codes IS
  'Activation codes for marketing platform';

  CALL after_create_table('offer.codes');
COMMIT;

-- offers.activations
BEGIN;
  CALL watch_create_table('offer.activations');

  CREATE TABLE offer.activations (
    code_num uuid PRIMARY KEY REFERENCES offer.codes(code_num),
    account_id uuid NOT NULL REFERENCES client.accounts(id),

    activated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  COMMENT ON TABLE offer.activations
  IS 'User Preferences with sorting';

  CALL after_create_table('offer.activations');
COMMIT;

-- offer.plans
BEGIN;
  CALL watch_create_table('offer.plans');

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

  CALL after_create_table('offer.plans');
COMMIT;

-- offer.features
BEGIN;
  CALL watch_create_table('offer.features');

  CREATE TABLE offer.features (
    plan_id uuid NOT NULL REFERENCES offer.plans(id),
    feature_id uuid NOT NULL REFERENCES setup.features(id),

    amount smallint NOT NULL,

    UNIQUE (plan_id, feature_id)
  );

  COMMENT ON TABLE offer.features
  IS 'Assignment of Features to a Plan by Ammount';

  CALL after_create_table('offer.features');
COMMIT;

-- offer.subscriptions
BEGIN;
  CALL watch_create_table('offer.subscriptions');

  CREATE TABLE offer.subscriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id uuid NOT NULL REFERENCES client.accounts(id),
    plan_id uuid NOT NULL REFERENCES offer.plans(id),

    quantity smallint NOT NULL DEFAULT 1,
    price numeric(10,2) NOT NULL,
    cycle text NOT NULL CHECK(cycle IN('weekly','monthly','quarterly','yearly')),

    metadata jsonb,

    is_active bool NOT NULL DEFAULT true,
    activated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    is_paused bool NOT NULL DEFAULT false,
    billed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    expires_at timestamptz NOT NULL
  );

  COMMENT ON TABLE offer.subscriptions
  IS 'Subscriptions to Plans from Accounts';

  CALL after_create_table('offer.subscriptions');
COMMIT;

-- offer.invoices
BEGIN;
  CALL watch_create_table('offer.invoices');

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

  CALL after_create_table('offer.invoices');
COMMIT;

-- offer.agreements
BEGIN;
  CALL watch_create_table('offer.agreements');

  CREATE TABLE offer.agreements (
    id uuid PRIMARY KEY,
    name text NOT NULL
  );

  COMMENT ON TABLE offer.agreements
  IS 'Contract agreement names';

  CALL after_create_table('offer.agreements');
COMMIT;

-- offer.revisions
BEGIN;
  CALL watch_create_table('offer.revisions');

  CREATE TABLE offer.revisions (
    id uuid PRIMARY KEY,

    revision SERIAL,
    agreement_id uuid NOT NULL REFERENCES offer.agreements(id),

    language_code varchar(2) NOT NULL REFERENCES setup.languages(code),
    body text NOT NULL
  );

  COMMENT ON TABLE offer.revisions
  IS 'Contract revisions possibly in different languages';

  CALL after_create_table('offer.revisions');
COMMIT;

-- offer.signatures
BEGIN;
  CALL watch_create_table('offer.signatures');

  CREATE TABLE offer.signatures (
    user_id uuid NOT NULL REFERENCES auth.users(id),
    revision_id uuid NOT NULL REFERENCES offer.revisions(id),

    agreed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, revision_id)
  );

  COMMENT ON TABLE offer.signatures
  IS 'User Signatures for agreements';

  CALL after_create_table('offer.signatures');
COMMIT;
