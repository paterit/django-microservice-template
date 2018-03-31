#!/usr/bin/env bash

# pull all needed base images

docker pull node:9.9-alpine37
docker pull python:3.6.3-alpine3.7
docker pull alpine:3.7
docker pull nginx:1.13-alpine
docker pull sebp/elk:623
docker pull gliderlabs/logspout:v3.1
docker pull postgres:10.3-alpine
