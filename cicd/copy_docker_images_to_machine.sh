#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster

docker save python:3.6.6-alpine3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save alpine:3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nginx:1.15.7-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save sebp/elk:623 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save gliderlabs/logspout:v3.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save postgres:11.1-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nicolargo/glances:v2.11.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save kamon/grafana_graphite | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save paterit/locustio-alpine:0.9.0-python3.6.6-alpine3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save paterit/sphinx-alpine:1.5.3-python3.6.6-alpine3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save paterit/node-behave-alpine:10.2-behave1.2.5-python3.6.5-alpine3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save paterit/django-postgresql-alpine:2.1.2-python3.6.6-node3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save paterit/buildbot-worker-docker:1.1.0-docker18.06.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load

