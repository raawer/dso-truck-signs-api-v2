#!/usr/bin/env bash
set -e

# Django's manage.py and the tsa_app package live in src/
cd /app/src

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

echo "Collecting static files ..."
python manage.py collectstatic --noinput

echo "Applying database migrations ..."
python manage.py migrate --noinput

CREATE_SUPERUSER="
from django.contrib.auth import get_user_model
import os
User = get_user_model()
NAME = os.environ['DJANGO_SUPERUSER_USERNAME']
if not User.objects.filter(username=NAME).exists():
    User.objects.create_superuser(
        NAME,
        os.environ['DJANGO_SUPERUSER_EMAIL'],
        os.environ['DJANGO_SUPERUSER_PASSWORD'])
"

echo "Ensuring the django superuser exists ..."
python manage.py shell -c "${CREATE_SUPERUSER}"


echo "Starting gunicorn ..."
gunicorn tsa_app.wsgi:application --bind 0.0.0.0:8000
