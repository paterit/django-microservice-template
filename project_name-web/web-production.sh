#!/usr/bin/env bash

# wait for postgres being ready to respond
python wait_for_postgres.py
python manage.py migrate
python manage.py collectstatic --no-input

# Prepare log files and start outputting logs to stdout
mkdir -p /opt/{{ project_name }}/logs
touch /opt/{{ project_name }}/logs/gunicorn.log
touch /opt/{{ project_name }}/logs/gunicorn-access.log
touch /opt/{{ project_name }}/logs/gunicorn-error.log
touch /opt/{{ project_name }}/logs/nginx-access.log
touch /opt/{{ project_name }}/logs/nginx-error.log
tail -n 0 -f /opt/{{ project_name }}/logs/*.log &

# create admin user if doesn't exist
echo "from django.contrib.auth.models import User;User.objects.create_superuser('admin', 'wojtek.semik@gmail.com', 'admin') if not User.objects.filter(username='admin').exists() else print('admin already created')" | python manage.py shell

/usr/local/bin/gunicorn {{ project_name }}.wsgi:application \
--name {{ project_name }}_django \
--bind 0.0.0.0:8000 \
--workers 2 \
--log-level=info \
--error-logfile=/opt/{{ project_name }}/logs/gunicorn-error.log \
--log-file=/opt/{{ project_name }}/logs/gunicorn.log \
--access-logfile=/opt/{{ project_name }}/logs/gunicorn-access.log \
"$@"
