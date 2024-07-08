-- schema support
CREATE SCHEMA IF NOT EXISTS support;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA support
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA support TO "${RUNCORE_HASURA_USER}";

-- table support.columns
BEGIN;
  CALL watch_create_table('support.columns');

  CREATE TABLE support.columns (
    id uuid PRIMARY KEY,
    sorting SERIAL,

    name text NOT NULL,

    is_public bool,
    is_done bool
  );

  CALL after_create_table('support.columns');
COMMIT;

-- table support.boards
BEGIN;
  CALL watch_create_table('support.boards');

  CREATE TABLE support.boards (
    id uuid PRIMARY KEY,

    name text NOT NULL,

    column_ids uuid[] NOT NULL
  );

  CALL after_create_table('support.boards');
COMMIT;

-- function support.boards_column_ids
CREATE OR REPLACE FUNCTION support.boards_check_column_ids()
RETURNS TRIGGER AS $$
DECLARE
  column_id UUID;
BEGIN
  -- Loop through each column_id in the column_ids array
  FOREACH column_id IN ARRAY NEW.column_ids LOOP
    -- Check if the column_id exists in the columns table
    IF NOT EXISTS (
      SELECT 1
      FROM support.columns sc
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

-- trigger support.boards_check_column_ids
CREATE OR REPLACE TRIGGER boards_check_column_ids
BEFORE INSERT OR UPDATE ON support.boards
FOR EACH ROW
EXECUTE FUNCTION support.boards_check_column_ids();

-- function support.boards_columns
CREATE OR REPLACE FUNCTION support.boards_columns(board support.boards)
RETURNS SETOF support.columns
AS $$
  SELECT *
  FROM support.columns
  WHERE id = ANY(board.column_ids);
$$ LANGUAGE sql STABLE;

-- support.issues
BEGIN;
  CALL watch_create_table('support.issues');
  
  CREATE TABLE support.issues (
    id uuid PRIMARY KEY,
    board_id uuid REFERENCES support.boards(id),
    column_id uuid REFERENCES support.columns(id),
    num SERIAL,
    ext_num text,
    title text,
    body text,
    metadata jsonb,
    is_done bool,
    created_at timestamptz NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );
  
  CALL after_create_table('support.issues');
COMMIT;

-- support.comments
BEGIN;
  CALL watch_create_table('support.comments');

  CREATE TABLE support.comments (
    id uuid PRIMARY KEY,
    issue_id uuid NOT NULL REFERENCES support.issues(id),

    body text NOT NULL,

    created_at timestamptz NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );

  CALL after_create_table('support.comments');
COMMIT;

-- support.relationships
BEGIN;
  CALL watch_create_table('support.relationships');

  CREATE TABLE support.relationships (
    id uuid PRIMARY KEY,
    forward_name text NOT NULL,
    backward_name text NOT NULL
  );

  CALL after_create_table('support.relationships');
COMMIT;

-- support.relates
BEGIN;
  CALL watch_create_table('support.relates');

  CREATE TABLE support.relates (
    id uuid PRIMARY KEY,
    relationship_id uuid NOT NULL REFERENCES support.relationships(id),
    from_issue_id uuid NOT NULL REFERENCES support.issues(id),
    to_issue_id uuid NOT NULL REFERENCES support.issues(id),

    UNIQUE(relationship_id, from_issue_id, to_issue_id)
  );

  CALL after_create_table('support.relates');
COMMIT;

