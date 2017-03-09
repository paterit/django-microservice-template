#!/usr/bin/env bash

docker save python:3.5 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save alpine:3.4 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nginx | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save sebp/elk:es500_l500_k500 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save gliderlabs/logspout | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save postgres | pv | docker $(docker-machine config {{ project_name }}-cicd) load
