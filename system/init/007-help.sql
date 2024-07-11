-- schema help
CREATE SCHEMA IF NOT EXISTS help;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA help
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA help TO "${RUNCORE_HASURA_USER}";

-- table help.columns
BEGIN;
  CALL watch_create_table('help.columns');

  CREATE TABLE help.columns (
    id uuid PRIMARY KEY,
    sorting SERIAL,

    name text NOT NULL,

    is_public bool,
    is_done bool
  );

  CALL after_create_table('help.columns');
COMMIT;

-- table help.boards
BEGIN;
  CALL watch_create_table('help.boards');

  CREATE TABLE help.boards (
    id uuid PRIMARY KEY,

    name text NOT NULL,

    column_ids uuid[] NOT NULL
  );

  CALL after_create_table('help.boards');
COMMIT;

-- function help.boards_column_ids
CREATE OR REPLACE FUNCTION help.boards_check_column_ids()
RETURNS TRIGGER AS $$
DECLARE
  column_id UUID;
BEGIN
  -- Loop through each column_id in the column_ids array
  FOREACH column_id IN ARRAY NEW.column_ids LOOP
    -- Check if the column_id exists in the columns table
    IF NOT EXISTS (
      SELECT 1
      FROM help.columns sc
      WHERE sc.column_id = column_id
    ) THEN
      -- Raise an exception if the column_id is not found
      RAISE EXCEPTION 'FK error. column % does not exists',
        column_id;
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger help.boards_check_column_ids
CREATE OR REPLACE TRIGGER boards_check_column_ids
BEFORE INSERT OR UPDATE ON help.boards
FOR EACH ROW
EXECUTE FUNCTION help.boards_check_column_ids();

-- function help.boards_columns
CREATE OR REPLACE FUNCTION help.boards_columns(board help.boards)
RETURNS SETOF help.columns
AS $$
  SELECT *
  FROM help.columns
  WHERE id = ANY(board.column_ids);
$$ LANGUAGE sql STABLE;

-- help.issues
BEGIN;
  CALL watch_create_table('help.issues');
  
  CREATE TABLE help.issues (
    id uuid PRIMARY KEY,
    board_id uuid REFERENCES help.boards(id),
    column_id uuid REFERENCES help.columns(id),
    num SERIAL,
    ext_num text,
    title text,
    body text,
    metadata jsonb,
    is_done bool,
    created_at timestamptz NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );
  
  CALL after_create_table('help.issues');
COMMIT;

-- help.comments
BEGIN;
  CALL watch_create_table('help.comments');

  CREATE TABLE help.comments (
    id uuid PRIMARY KEY,
    issue_id uuid NOT NULL REFERENCES help.issues(id),

    body text NOT NULL,

    created_at timestamptz NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );

  CALL after_create_table('help.comments');
COMMIT;

-- help.relationships
BEGIN;
  CALL watch_create_table('help.relationships');

  CREATE TABLE help.relationships (
    id uuid PRIMARY KEY,
    forward_name text NOT NULL,
    backward_name text NOT NULL
  );

  CALL after_create_table('help.relationships');
COMMIT;

-- help.relates
BEGIN;
  CALL watch_create_table('help.relates');

  CREATE TABLE help.relates (
    id uuid PRIMARY KEY,
    relationship_id uuid NOT NULL REFERENCES help.relationships(id),
    from_issue_id uuid NOT NULL REFERENCES help.issues(id),
    to_issue_id uuid NOT NULL REFERENCES help.issues(id),

    UNIQUE(relationship_id, from_issue_id, to_issue_id)
  );

  CALL after_create_table('help.relates');
COMMIT;

