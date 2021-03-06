#!/bin/bash

# installing dependencies
echo "Setting up dependencies..."

sudo apt install python3 python3-dev python3-pip postgresql libpq-dev \
  virtualenv postgresql-contrib python3-psycopg2 jq -y

# meta data
config_file="config.json"
backup_file_name="./backups/$(date +%Y-%m-%d-%T)"

db_user="$(jq -r '.db_connect.user' ${config_file})"
db_host="$(jq -r '.db_connect.host' ${config_file})"
db_password="$(jq -r '.db_connect.password' ${config_file})"
db_database="$(jq -r '.db_connect.database' ${config_file})"

# setup the virtual environment
echo "Setting up environment..."

sudo rm -r venv
virtualenv -p python3 venv
. venv/bin/activate
pip install -r requirements.txt

# pre back up meta
echo "Setting up the backup..."

mkdir backups
export PGPASSWORD="$db_password"

# back up script visit https://gist.github.com/ajaidanial/91724d85bd899e3e4a905fa73a49f8b1 for more info
pg_dump -F t -h "$db_host" -U "$db_user" "$db_database" >"$backup_file_name".backup
gzip "$backup_file_name".backup

# post back up meta
unset PGPASSWORD

# run the main script
python main.py
