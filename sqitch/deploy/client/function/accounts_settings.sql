-- Deploy AppCore:client/function/accounts_settings to pg

BEGIN;

CREATE FUNCTION client.accounts_settings(account client.accounts)
RETURNS SETOF setup.settings AS $$
  SELECT
    cs.id,
    cs.sorting,
    cs.category,
    cs.name,
    cs.description,
    cs.feature_id,
    cs.datatype,
    COALESCE(us.value, cs.value) AS value
  FROM setup.settings cs
  LEFT OUTER JOIN client.settings us
    ON (us.setting_id = cs.id)
  WHERE us.account_id = account.id;
$$ LANGUAGE sql STABLE;

COMMIT;
