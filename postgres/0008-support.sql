-- schema support
CREATE SCHEMA IF NOT EXISTS support;

-- necessary for hasura user to access and track objects
ALTER DEFAULT PRIVILEGES IN SCHEMA support
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${RUNCORE_HASURA_USER}";
GRANT USAGE ON SCHEMA support TO "${RUNCORE_HASURA_USER}";

-- support.columns
BEGIN;
  CALL create_pre_migration('support.columns');

  CREATE TABLE support.columns (
    id uuid PRIMARY KEY,
    sorting SERIAL,

    name text NOT NULL,

    is_public bool,
    is_done bool
  );

  CALL create_post_migration('support.columns');
COMMIT;

-- support.boards
BEGIN;
  CALL create_pre_migration('support.boards');

  CREATE TABLE support.boards (
    id uuid PRIMARY KEY,

    name text NOT NULL,

    column_ids uuid[] NOT NULL REFERENCES support.columns(id)
  );

  CALL create_post_migration('support.boards');
COMMIT;

-- support.issues
BEGIN;
  CALL create_pre_migration('support.issues');
  
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
    created_at timestamptz NOT NULL DEFAULT (now()),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );
  
  CALL create_post_migration('support.issues');
COMMIT;

-- support.comments
BEGIN;
  CALL create_pre_migration('support.comments');

  CREATE TABLE support.comments (
    id uuid PRIMARY KEY,
    issue_id uuid NOT NULL REFERENCES support.issues(id),

    body text NOT NULL,

    created_at timestamptz NOT NULL DEFAULT (now()),
    created_by uuid NOT NULL REFERENCES auth.users(id)
  );

  CALL create_post_migration('support.comments');
COMMIT;

-- support.relationships
BEGIN;
  CALL create_pre_migration('support.relationships');

  CREATE TABLE support.relationships (
    id uuid PRIMARY_KEY,
    forward_name text NOT NULL,
    backward_name text NOT NULL
  );

  CALL create_post_migration('support.relationships');
COMMIT;

-- support.relates
BEGIN;
  CALL create_pre_migration('support.relates');

  CREATE TABLE support.relates (
    id uuid PRIMARY_KEY,
    relationship_id uuid NOT NULL REFERENCES support.relationships(id),
    from_issue_id uuid NOT NULL REFERENCES support.issues(id),
    to_issue_id uuid NOT NULL REFERENCES support.issues(id),

    UNIQUE(relationship_id, from_issue_id, to_issue_id)
  );

  CALL create_post_migration('support.relates');
COMMIT;
