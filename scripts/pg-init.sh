#!/bin/bash

set -Eeuo pipefail

source /usr/local/bin/docker-entrypoint.sh

# Function to replace placeholders with environment variables and execute SQL
process_sql_files() {
	local vars=$(env | cut -d= -f1)

	for sql_file in ./*.sql; do
		if [ -f "$sql_file" ]; then
			echo "Processing $sql_file..."
		
			# Read the content and perform substitutions using environment variables
			local content=$(<"$sql_file")

			for var in $vars; do
				var_name="${var}"
				var_value="${!var_name}"
				content="${content//\$\{$var_name\}/$var_value}"
			done

			# Pipe the content directly to psql
			echo "$content" | PGHOST= PGHOSTADDR= psql -v QUIET=1 --username "$POSTGRES_USER" --no-password --no-psqlrc --dbname "$POSTGRES_DB"
		fi
	done
}

# fix arguments if needed 
if [ "$#" -eq 0 ] || [ "$1" != 'postgres' ]; then
	set -- postgres "$@"
fi

# setup base environment
docker_setup_env

# setup data directories and permissions (when run as root)
docker_create_db_directories

if [ "$(id -u)" = '0' ]; then
	echo "Dropping now to postgres user"

	# then restart script as postgres user
	exec gosu postgres "$BASH_SOURCE" "$@"
fi

# only run initialization on an empty data directory
if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
	docker_verify_minimum_env
	docker_init_database_dir
	pg_setup_hba_conf "$@"

	cat <<-'EOM'
		Data directory created and setup
	EOM
else
	cat <<-'EOM'
		Data directory initialized
	EOM
fi

# PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
# e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"

# Start temp server
docker_temp_server_start "$@"

# Setup database
docker_setup_db

# Run init files
process_sql_files

# Stop temp server
docker_temp_server_stop

unset PGPASSWORD

# Run main server
exec "$@"