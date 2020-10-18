#!/usr/bin/env bash

# pull all needed base images to dev local machine
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME
unset DOCKER_MACHINE_IP

docker pull python:3.8.0-alpine3.10
docker pull alpine:3.8
docker pull nginx:1.17.6-alpine
docker pull sebp/elk:792
docker pull gliderlabs/logspout:v3.2.6
docker pull postgres:12.1-alpine
docker pull nicolargo/glances:v2.11.1
docker pull kamon/grafana_graphite
docker pull paterit/locustio:0.13.2-3.7.5-alpine3.10
docker pull paterit/sphinx:2.2.1-python3.8.0-alpine3.10
docker pull paterit/node-behave:13.1-alpine-behave1.2.6-python3
docker pull paterit/django-postgresql:3.1.2-python3.9.0-alpine3.12
docker pull paterit/buildbot-worker-docker:2.8.4-docker18.06.3
docker pull portainer/portainer:1.22.2
