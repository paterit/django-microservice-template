#!/usr/bin/env bash

# pull all needed base images to dev local machine
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME
unset DOCKER_MACHINE_IP

docker pull python:3.9.0-alpine3.12
docker pull alpine:3.8
docker pull nginx:1.19.4-alpine
docker pull sebp/elk:793
docker pull gliderlabs/logspout:v3.2.12
docker pull postgres:13.1-alpine
docker pull nicolargo/glances
docker pull kamon/grafana_graphite
docker pull paterit/locustio:1.4.1-3.8.6-alpine3.12
docker pull paterit/sphinx:3.3.1-python3.9.0-alpine3.12
docker pull paterit/node-behave:15.2-alpine-behave1.2.6-python3
docker pull paterit/django-postgresql:3.1.3-python3.9.0-alpine3.12
docker pull paterit/buildbot-worker-docker:2.8.4-docker18.06.3
docker pull portainer/portainer:1.24.1
