#!/bin/bash
cd "$(dirname "$0")"

# create initial .env
cp .env.example .env

# create empty project directories
mkdir pgadmin-conf
mkdir postgres-data

# initialize database
docker-compose -f docker-compose.migrate.yml run --rm migrate

# fix permissions
sudo chmod 775 postgres-data

# fix ownership
sudo chown -R 5050:5050 pgadmin-conf
