#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster
VER_PYTHON=python:3.6.6-alpine3.8
VER_ALPINE=alpine:3.8
VER_NGINX=nginx:1.15.9-alpine
VER_ELK=sebp/elk:661
VER_LOGSPOUT=gliderlabs/logspout:v3.2.6
VER_POSTGRES=postgres:11.2-alpine
VER_GLANCES=nicolargo/glances:v2.11.1
VER_LOCUST=paterit/locustio:0.11.0-3.7.2-alpine3.9
VER_SPHINX=paterit/sphinx:1.8.5-python3.7.2-alpine3.9
VER_BEHAVE=paterit/node-behave:11.12-alpine-behave1.2.6-python3
VER_DJANGO=paterit/django-postgresql:2.1.7-python3.7.2-alpine3.9
VER_BUILDBOT=paterit/buildbot-worker-docker:2.1.0-docker18.06.3
VER_PORTAINER=portainer/portainer:1.20.2

[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_PYTHON) ] || docker save $VER_PYTHON | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_ALPINE) ] || docker save $VER_ALPINE | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_NGINX) ] || docker save $VER_NGINX | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_ELK) ] || docker save $VER_ELK | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_LOGSPOUT) ] || docker save $VER_LOGSPOUT | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_POSTGRES) ] || docker save $VER_POSTGRES | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_GLANCES) ] || docker save $VER_GLANCES | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q kamon/grafana_graphite) ] || docker save kamon/grafana_graphite | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_LOCUST) ] || docker save $VER_LOCUST | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_SPHINX) ] || docker save $VER_SPHINX | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_BEHAVE) ] || docker save $VER_BEHAVE | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_DJANGO) ] || docker save $VER_DJANGO | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_BUILDBOT) ] || docker save $VER_BUILDBOT | pv | docker $(docker-machine config {{ project_name }}-cicd) load
[ ! -z $(docker $(docker-machine config {{ project_name }}-cicd) images -q $VER_PORTAINER) ] || docker save $VER_PORTAINER | pv | docker $(docker-machine config {{ project_name }}-cicd) load

