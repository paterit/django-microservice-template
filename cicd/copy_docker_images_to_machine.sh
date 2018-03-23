#!/usr/bin/env bash

docker save python:3.6.4 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save python:3.6.4-alpine3.7 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save alpine:3.7 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nginx:1.13-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save sebp/elk:623 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save gliderlabs/logspout:v3.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save postgres:10.3-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load

