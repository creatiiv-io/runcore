-- Deploy AppCore:core/function/accounts_settings to pg

BEGIN;

CREATE FUNCTION accounts_settings(account accounts)
RETURNS SETOF settings AS $$
  WITH t AS (
    SELECT
  SELECT
    s.id,
    s.sorting,
    s.category,
    s.name,
    s.description,
    s.feature_id,
    s.datatype,
    COALESCE(acs.value, s.value) AS value
  FROM settings s
  LEFT OUTER JOIN accounts_changed_settings acs
    ON (acs.setting_id = s.id)

$$ LANGUAGE sql STABLE;

COMMIT;
