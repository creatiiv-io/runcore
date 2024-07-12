#!/bin/bash

if [ "$(id -u)" = '0' ]; then
	# then restart script as postgres user
	exec gosu postgres "$BASH_SOURCE" "$@"
fi

set -Eeuo pipefail

vars=$(env | cut -d= -f1)

for init in /initfiles/*.sql; do
  if [ -f "$init" ]; then
    layer=$(echo "$init" | sed -E 's:.*/[0-9]+-(.*)\..*:\1:')

    echo "processing "'"'$layer'"'" database layer"

    # Read the content and perform substitutions using environment variables
    content=$(<"$init")

    for var in $vars; do
    	var_name="${var}"
    	var_value="${!var_name}"
    	content="${content//\$\{$var_name\}/$var_value}"
    done

    # Pipe the content directly to psql
    echo "$content" | PGHOST= PGHOSTADDR= psql -v QUIET=1 --username "$POSTGRES_USER" --no-password --no-psqlrc --dbname "$POSTGRES_DB"
  fi
done
