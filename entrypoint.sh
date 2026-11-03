#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect ..."

DB_CHECK="import os, psycopg2; psycopg2.connect(
    dbname=os.environ['DB_NAME'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASSWORD'],
    host=os.environ['DB_HOST'],
    port=os.environ['DB_PORT'],
    connect_timeout=3)"

# Wait for the database to be up and ready, if not ready, then sleep for 5 seconds
while ! python -c "${DB_CHECK}" 2>/dev/null; do
  echo "postgres is unavailable - sleeping"
  sleep 5
done

echo "PostgreSQL is active"

python manage.py collectstatic --noinput

#TODO add migrations
echo "Postgresql migrations finished"

gunicorn tsa_app.wsgi:application --bind 0.0.0.0:8000
