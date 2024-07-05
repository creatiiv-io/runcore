-- Deploy AppCore:core/function/accounts_settings to pg

BEGIN;

CREATE FUNCTION core.accounts_settings(account core.accounts)
RETURNS SETOF core.settings AS $$
  SELECT
    s.id,
    s.sorting,
    s.category,
    s.name,
    s.description,
    s.feature_id,
    s.datatype,
    COALESCE(acs.value, s.value) AS value
  FROM core.settings s
  LEFT OUTER JOIN core.accounts_settings acs
    ON (acs.setting_id = s.id)
$$ LANGUAGE sql STABLE;

COMMIT;
