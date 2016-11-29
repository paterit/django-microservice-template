#!/usr/bin/env bash

# Prepare log files and start outputting logs to stdout
touch /opt/{{ project_name }}/logs/https/nginx-access.log
touch /opt/{{ project_name }}/logs/https/nginx-error.log
tail -n 0 -f /opt/{{ project_name }}/logs/https/*.log &

nginx -g 'daemon off;'
