#!/usr/bin/env bash

# pull all needed base images

docker pull python:3.6.6-alpine3.8
docker pull alpine:3.8
docker pull nginx:1.13-alpine
docker pull sebp/elk:623
docker pull gliderlabs/logspout:v3.1
docker pull postgres:10.3-alpine
docker pull nicolargo/glances:v2.11.1
docker pull kamon/grafana_graphite
