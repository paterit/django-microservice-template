#!/usr/bin/env bash

# pull all needed base images

docker pull python:3.6.6-alpine3.8
docker pull alpine:3.8
docker pull nginx:1.15.9-alpine
docker pull sebp/elk:661
docker pull gliderlabs/logspout:v3.2.6
docker pull postgres:11.2-alpine
docker pull nicolargo/glances:v2.11.1
docker pull kamon/grafana_graphite
docker pull paterit/locustio:0.11.0-3.7.2-alpine3.9
docker pull paterit/sphinx:1.5.3-python3.6.6-alpine3.8
docker pull paterit/node-behave:10.2-behave1.2.5-python3.6.5-alpine3.8
docker pull paterit/django-postgresql:2.1.7-python3.7.2-alpine3.9
docker pull paterit/buildbot-worker-docker:1.1.0-docker18.06.1
docker pull portainer/portainer:1.20.2
