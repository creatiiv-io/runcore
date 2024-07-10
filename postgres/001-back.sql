-- back schema
CREATE SCHEMA IF NOT EXISTS back;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA back
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA core TO "${RUNCORE_HASURA_USER}";

-- table back.logs
BEGIN;
  CALL watch_create_table('back.logs');

  CREATE TABLE back.logs (
    entity entity_scoped NOT NULL,
    key uuid NOT NULL,
    data jsonb NOT NULL,
    timestamp timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (entity, key, timestamp)
  );

  COMMENT ON TABLE back.logs IS
  'Features that can switch features on and off';

  CALL after_create_table('back.logs');
COMMIT;

-- procedure watch_create_table
CREATE OR REPLACE FUNCTION back.watch(
  target_table entity_scoped
) RETURNS void AS $$
BEGIN
  EXECUTE format(
    'CREATE OR REPLACE TRIGGER $I_backup_on_update
     BEFORE UPDATE ON %I
     FOR EACH ROW
     EXECUTE FUNCTION back.update();',
    target_table, target_table
  );
END;
$$ LANGUAGE plpgsql;

-- procedure watch_create_table
CREATE OR REPLACE FUNCTION back.unwatch(
  target_table entity_scoped
) RETURNS void AS $$
BEGIN
  EXECUTE format(
    'DROP TRIGGER $I ON %I CASCADE;',
    target_table || '_backup_on_update', target_table
  );
END;
$$ LANGUAGE plpgsql;

-- function back.update
CREATE OR REPLACE FUNCTION back.updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- function back.update
CREATE OR REPLACE FUNCTION back.update()
RETURNS TRIGGER $$
BEGIN
  INSERT INTO back.logs (
    entity,
    key,
    data
  ) VALUES (
    pg_type(OLD),
    OLD.id,
    row_to_jsonb(OLD)
  )
END;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION back.history(
  record ANYELEMENT
) RETURNS SETOF ANYELEMENT AS $$
  SELECT rec.*
  FROM back.logs log
  JOIN LATERAL jsonb_populate_record(record, log.data) rec ON true
  WHERE entity = pg_typeof(record)::text
    AND entity_id = (record).id
ORDER BY timestamp;
$$ LANGUAGE sql;
