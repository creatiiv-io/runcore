#!/bin/bash

# Ensure the script is run as the postgres user
if [ "$(id -u)" = '0' ]; then
  # Restart the script as the postgres user
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

echo "
  SELECT *
  FROM table_insert_order();
" | PGHOST= PGHOSTADDR= psql -v QUIET=1 ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password --no-psqlrc --dbname "$POSTGRES_DB" -t -A
