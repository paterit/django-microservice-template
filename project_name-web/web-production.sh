#!/usr/bin/env bash

# wait for postgres being ready to respond
echo "Verifying if postgres is up ..."
python wait_for_postgres.py
echo "Django migrate db ..."
python manage.py migrate
echo "Django collectstatic ..."
python manage.py collectstatic --no-input

# Prepare log files and start outputting logs to stdout
echo "Prepare files for logs ..."
mkdir -p /opt/{{ project_name }}/logs/web
touch /opt/{{ project_name }}/logs/web/gunicorn.log
touch /opt/{{ project_name }}/logs/web/gunicorn-access.log
touch /opt/{{ project_name }}/logs/web/gunicorn-error.log
touch /opt/{{ project_name }}/logs/web/django-errors.log
touch /opt/{{ project_name }}/logs/web/django-debug.log
tail -n 0 -f /opt/{{ project_name }}/logs/web/*.log &

# create admin user if doesn't exist
echo "Create django admin user if one doesn't exist ..."
echo "from django.contrib.auth.models import User;User.objects.create_superuser('admin', 'wojtek.semik@gmail.com', 'admin') if not User.objects.filter(username='admin').exists() else print('admin already created')" | python manage.py shell

echo "Start gunicorn ..."
/usr/local/bin/gunicorn {{ project_name }}.wsgi:application \
--name {{ project_name }}_django \
--bind 0.0.0.0:8000 \
--workers 2 \
--log-level=info \
--error-logfile=/opt/{{ project_name }}/logs/web/gunicorn-error.log \
--log-file=/opt/{{ project_name }}/logs/web/gunicorn.log \
--access-logfile=/opt/{{ project_name }}/logs/web/gunicorn-access.log \
"$@"
