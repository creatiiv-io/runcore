-- Deploy AppCore:user/table/accounts to pg

BEGIN;

CREATE TABLE user.accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  signup_number int GENERATED ALWAYS AS IDENTITY,
  referral_code text,
  referred_by uuid REFERENCES user.accounts(id),

  name text NOT NULL,
  language_code varchar(2) NOT NULL REFERENCES user.languages(code),

  is_active bool NOT NULL DEFAULT true,
  is_deleted bool NOT NULL DEFAULT false
);

COMMENT ON TABLE user.accounts
IS 'Multi-user Accounts';

COMMIT;
