#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster
VER_PYTHON=3.6.6-alpine3.8
VER_ALPINE=3.8
VER_NGINX=1.15.9-alpine
VER_ELK=661
VER_LOGSPOUT=v3.2.6
VER_POSTGRES=11.2-alpine
VER_GLANCES=v2.11.1
VER_LOCUST=0.11.0-3.7.2-alpine3.9
VER_SPHINX=1.8.5-python3.7.2-alpine3.9
VER_BEHAVE=11.12-alpine-behave1.2.6-python3
VER_DJANGO=2.1.7-python3.7.2-alpine3.9
VER_BUILDBOT=2.1.0-docker18.06.3
VER_PORTAINER=1.20.2

[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q python:$VER_PYTHON) ] || docker save python:$VER_PYTHON | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q alpine:$VER_ALPINE) ] || docker save alpine:$VER_ALPINE | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q nginx:$VER_NGINX) ] || docker save nginx:$VER_NGINX | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q sebp/elk:$VER_ELK) ] || docker save sebp/elk:$VER_ELK | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q gliderlabs/logspout:$VER_LOGSPOUT) ] || docker save gliderlabs/logspout:$VER_LOGSPOUT | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q postgres:$VER_POSTGRES) ] || docker save postgres:$VER_POSTGRES | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q nicolargo/glances:$VER_GLANCES) ] || docker save nicolargo/glances:$VER_GLANCES | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q kamon/grafana_graphite) ] || docker save kamon/grafana_graphite | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/locustio:$VER_LOCUST) ] || docker save paterit/locustio:$VER_LOCUST | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/sphinx:$VER_SPHINX) ] || docker save paterit/sphinx:$VER_SPHINX | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/node-behave:$VER_BEHAVE) ] || docker save paterit/node-behave:$VER_BEHAVE | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/django-postgresql:$VER_DJANGO) ] || docker save paterit/django-postgresql:$VER_DJANGO | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q paterit/buildbot-worker-docker:$VER_BUILDBOT) ] || docker save paterit/buildbot-worker-docker:$VER_BUILDBOT | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q portainer/portainer:$VER_PORTAINER) ] || docker save portainer/portainer:$VER_PORTAINER | pv | docker $(docker-machine config {{ project_name }}-cicd) load

