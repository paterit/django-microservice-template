#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster

[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q python:3.6.6-alpine3.8) ] || docker save python:3.6.6-alpine3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q alpine:3.8) ] || docker save alpine:3.8 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q nginx:1.15.9-alpine) ] || docker save nginx:1.15.9-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q sebp/elk:661) ] || docker save sebp/elk:661 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q gliderlabs/logspout:v3.2.6) ] || docker save gliderlabs/logspout:v3.2.6 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q postgres:11.2-alpine) ] || docker save postgres:11.2-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q nicolargo/glances:v2.11.1) ] || docker save nicolargo/glances:v2.11.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q kamon/grafana_graphite) ] || docker save kamon/grafana_graphite | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/locustio:0.11.0-3.7.2-alpine3.9) ] || docker save paterit/locustio:0.11.0-3.7.2-alpine3.9 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/sphinx:1.8.5-python3.7.2-alpine3.9) ] || docker save paterit/sphinx:1.8.5-python3.7.2-alpine3.9 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/node-behave:11.12-alpine-behave1.2.6-python3) ] || docker save paterit/node-behave:11.12-alpine-behave1.2.6-python3 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/django-postgresql:2.1.7-python3.7.2-alpine3.9) ] || docker save paterit/django-postgresql:2.1.7-python3.7.2-alpine3.9 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/buildbot-worker-docker:2.1.0-docker18.06.3) ] || docker save paterit/buildbot-worker-docker:2.1.0-docker18.06.3 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q portainer/portainer:1.20.2) ] || docker save portainer/portainer:1.20.2 | pv | docker $(docker-machine config {{ project_name }}-cicd) load

