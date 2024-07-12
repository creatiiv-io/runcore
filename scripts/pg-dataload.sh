#!/bin/bash

# Ensure the script is run as the postgres user
if [ "$(id -u)" = '0' ]; then
  # Restart the script as the postgres user
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

# Function to get conflict handling statements from PostgreSQL
get_conflicts() {
  local table=$1
  local update_columns=$2

  echo "
    SELECT 'ON CONFLICT ON CONSTRAINT ' || con.conname || ' DO UPDATE SET $update_columns'
    FROM pg_constraint con
    WHERE con.conrelid = '$table'::regclass
    AND con.contype IN ('p', 'u');
  " | PGHOST= PGHOSTADDR= psql -v QUIET=1 ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password --no-psqlrc --dbname "$POSTGRES_DB" -t -A
}

# Function to process each file
load_datafile() {
  local seedfile="$1"
  local table=$(basename "$seedfile")
  local temp_table="temp_${table//./_}"
  local headers=$(head -n 1 "$seedfile")
  local columns=${headers//:/, }
  local update_columns=$(echo $columns | sed 's/[^,]*/\0 = EXCLUDED.&/g')

  echo 'updating table "'$table'" with new settings'

  # Get conflict handling statements for the table
  local conflict_statements=$(get_conflicts "$table" "$update_columns")

  # Execute the SQL commands within a single transaction
  local dataload_sql="
    BEGIN;

    -- Create a temporary table with the same structure as the target table
    CREATE TEMP TABLE $temp_table AS SELECT * FROM $table LIMIT 0;

    -- Copy data from the CSV file into the temporary table
    \COPY $temp_table($columns) FROM '$seedfile' DELIMITER ':' CSV HEADER;

    -- Insert data. Handle conflicts if any exist
    INSERT INTO $table ($columns)
    SELECT $columns FROM $temp_table
    $conflict_statements;

    -- Drop the temporary table to clean up
    DROP TABLE IF EXISTS $temp_table;

    COMMIT;
  "

  # echo "$conflict_statements"
  # echo "$dataload_sql"
  echo "$dataload_sql" | PGHOST= PGHOSTADDR= psql -v QUIET=1 ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password --no-psqlrc --dbname "$POSTGRES_DB" -t -A
}

# Process each table in the correct order
for tablename in $(pg_tableorder); do
  # Check if the file exists in the datafiles
  if [ -f "/datafiles/$tablename" ]; then
    # load data from file
    load_datafile "/datafiles/$tablename"
  fi
done
