#!/usr/bin/env bash

# Instead of pulling every time from internet all needed images
# we copy them from local machine into docker-machine, what makes 
# the whole process much faster

# $1 - image_name
load_if_differ () {
  local image=$1
  # dirty hack to avoid replacing by django templating
  local cbo="{{"
  local cbc="}}"
  local digest_docker_machine="$(docker $(docker-machine config {{ project_name }}-cicd) image inspect --format="'"$cbo".Id"$cbc"'" $image)"
  local digest_local=$(docker image inspect --format="'"$cbo".Id"$cbc"'" $image)
  if ! [[ $digest_local = $digest_docker_machine ]]; then
    echo "$image"
    echo "LOCAL         : $digest_local"
    echo "DOCKER-MACHINE: $digest_docker_machine"
    docker $(docker-machine config {{ project_name }}-cicd) rmi $image
    docker save $image | pv | docker $(docker-machine config {{ project_name }}-cicd) load
  fi
}


unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME
unset DOCKER_MACHINE_IP

declare -a ver=("python:3.8.0-alpine3.10"
                "alpine:3.8"
                "nginx:1.19.3-alpine"
                "sebp/elk:792"
                "gliderlabs/logspout:v3.2.12"
                "postgres:12.1-alpine"
                "nicolargo/glances:v2.11.1"
                "paterit/locustio:1.3.1-3.8.6-alpine3.12"
                "paterit/sphinx:2.2.1-python3.8.0-alpine3.10"
                "paterit/node-behave:13.1-alpine-behave1.2.6-python3"
                "paterit/django-postgresql:3.1.2-python3.9.0-alpine3.12"
                "paterit/buildbot-worker-docker:2.8.4-docker18.06.3"
                "portainer/portainer:1.22.2"
                "kamon/grafana_graphite"
)

for i in "${ver[@]}"
do
   load_if_differ $i
done
