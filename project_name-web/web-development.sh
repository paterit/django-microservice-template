#!/usr/bin/env bash

# wait for postgres being ready to respond
python wait_for_postgres.py
python manage.py migrate
python manage.py collectstatic --no-input
# create admin user if doesn't exist
echo "from django.contrib.auth.models import User;User.objects.create_superuser('admin', 'wojtek.semik@gmail.com', 'admin') if not User.objects.filter(username='admin').exists() else print('admin already created')" | python manage.py shell
#/usr/local/bin/gunicorn {{ project_name }}.wsgi:application -w 2 -b 0.0.0.0:8000 --reload --access-logfile /var/log/gunicorn_access.log --error-logfile /var/log/gunicorn_error.log --log-level debug 
/usr/local/bin/gunicorn {{ project_name }}.wsgi:application -w 2 -b 0.0.0.0:8000 --reload