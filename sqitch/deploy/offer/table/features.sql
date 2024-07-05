-- Deploy AppCore:offer/table/features to pg

BEGIN;

CREATE TABLE offer.features (
  plan_id uuid NOT NULL REFERENCES offer.plans(id),
  feature_id uuid NOT NULL REFERENCES core.features(id),

  amount smallint NOT NULL,

  UNIQUE (plan_id, feature_id)
);

COMMENT ON TABLE offer.features
IS 'Assignment of Features to a Plan by Ammount';

COMMIT;
