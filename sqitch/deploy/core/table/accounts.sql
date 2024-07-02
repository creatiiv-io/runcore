-- Deploy AppCore:core/table/accounts to pg

BEGIN;

CREATE TABLE core.accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  signup_number int GENERATED ALWAYS AS IDENTITY,
  referral_code text,
  referred_by uuid REFERENCES core.accounts(id),

  name text NOT NULL,
  language varchar(2) NOT NULL REFERENCES core.languages(language),

  is_active bool NOT NULL DEFAULT true,
  is_deleted bool NOT NULL DEFAULT false
);

COMMENT ON TABLE core.accounts
IS 'Multi-user Accounts';

COMMIT;
