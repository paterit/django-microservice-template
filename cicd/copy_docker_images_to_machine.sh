#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster

docker save node:9.9-alpine37 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save python:3.6.3-alpine3.7 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save alpine:3.7 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save nginx:1.13-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save sebp/elk:623 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save gliderlabs/logspout:v3.1 | pv | docker $(docker-machine config {{ project_name }}-cicd) load
docker save postgres:10.3-alpine | pv | docker $(docker-machine config {{ project_name }}-cicd) load

