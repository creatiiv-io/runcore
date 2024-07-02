-- Deploy AppCore:core/table/plans_have_features to pg

BEGIN;

CREATE TABLE core.plans_have_features (
  plan_id uuid NOT NULL REFERENCES core.plans(id),
  feature_id uuid NOT NULL REFERENCES core.features(id),

  amount smallint NOT NULL,

  UNIQUE (plan_id, feature_id)
);

COMMENT ON TABLE core.plans_have_features
IS 'Assignment of Features to a Plan by Ammount';

COMMIT;
