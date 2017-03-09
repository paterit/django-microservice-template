#!/usr/bin/env bash

docker save python:3.6 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save alpine:3.5 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nginx:1.11 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save sebp/elk:521 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save gliderlabs/logspout | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save postgres:9.6 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
