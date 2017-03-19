#!/usr/bin/env bash

docker-machine create {{ project_name }}-cicd --driver virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 2
docker-machine start {{ project_name }}-cicd
eval $(docker-machine env {{ project_name }}-cicd)
cp $DOCKER_CERT_PATH/ca.pem ./cicd/worker/certs
cp $DOCKER_CERT_PATH/cert.pem ./cicd/worker/certs
cp $DOCKER_CERT_PATH/key.pem ./cicd/worker/certs
eval $(docker-machine env -u)
docker-machine ssh {{ project_name }}-cicd 'sudo /bin/su -c "echo sysctl -w -q vm.max_map_count=262144 >> /var/lib/boot2docker/bootlocal.sh"'
docker-machine ssh {{ project_name }}-cicd 'sudo chmod +x /var/lib/boot2docker/bootlocal.sh'
docker-machine ssh {{ project_name }}-cicd sudo sysctl -w -q vm.max_map_count=262144
docker-machine env {{ project_name }}-cicd | sed s/export\ // | sed s/\"//g > cicd/cicd.docker.env