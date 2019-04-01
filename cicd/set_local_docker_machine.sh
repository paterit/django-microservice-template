#!/usr/bin/env bash

# It creates and prepare docker-machine to which buildbot worker will be deploying containers
# when run more than once should create docker-machine propelry if one does not exists, and keep running one in good shape

# if virtualbox fail creation and start asking you for password use this to resolve the problem
# to find out the <vm-uuid> type ps ax | grep vbox
# vboxmanage startvm 37573512-780e-4eed-ae2a-570e752ecde0 --type emergencystop
# http://stackoverflow.com/questions/35169724/vm-in-virtualbox-is-already-locked-for-a-session-or-being-unlocked

# create docker machine
docker-machine create {{ project_name }}-cicd \
    --driver virtualbox \
    --virtualbox-memory 6144 \
    --virtualbox-cpu-count 2 \
    --virtualbox-disk-size 20000

# start docker machine
docker-machine start {{ project_name }}-cicd
# set env variables for docker that points to docker machine
eval $(docker-machine env {{ project_name }}-cicd)
# copy certs for secure connection between CICD worker and docker host
cp $DOCKER_CERT_PATH/ca.pem ./cicd/worker/certs
cp $DOCKER_CERT_PATH/cert.pem ./cicd/worker/certs
cp $DOCKER_CERT_PATH/key.pem ./cicd/worker/certs
# unset env variables for docker
eval $(docker-machine env -u)
# set params on docker host to be able to host kibana stack
# add command to be issued every time docker host starts
docker-machine ssh {{ project_name }}-cicd 'sudo /bin/su -c "echo sysctl -w -q vm.max_map_count=262144 >> /var/lib/boot2docker/bootlocal.sh"'
docker-machine ssh {{ project_name }}-cicd 'sudo chmod +x /var/lib/boot2docker/bootlocal.sh'
# run it to take imidiate efect on currently runining docker host
docker-machine ssh {{ project_name }}-cicd sudo sysctl -w -q vm.max_map_count=262144
# place env variables to be uesed by cicd worker
docker-machine env {{ project_name }}-cicd | sed s/export\ // | sed s/\"//g > cicd/cicd.docker.env

# get docker machine IP and set it in env file where env variable for docker and docker compose are kept
DOCKER_MACHINE_IP=$(docker-machine ip {{ project_name }}-cicd)
sed -i "s|DOCKER_MACHINE_IP\=localhost|DOCKER_MACHINE_IP\=$DOCKER_MACHINE_IP|" ./env

# replace values for some make commands with actual values from docker-machine
eval $(docker-machine env {{ project_name }}-cicd)
sed -i "s|DOCKER_TLS_VERIFY\=$|DOCKER_TLS_VERIFY\=$DOCKER_TLS_VERIFY|" ./Makefile
sed -i "s|DOCKER_HOST\=$|DOCKER_HOST\=$DOCKER_HOST|" ./Makefile
sed -i "s|DOCKER_CERT_PATH\=$|DOCKER_CERT_PATH\=$DOCKER_CERT_PATH|" ./Makefile
sed -i "s|DOCKER_MACHINE_NAME\=$|DOCKER_MACHINE_NAME\=$DOCKER_MACHINE_NAME|" ./Makefile
sed -i "s|DOCKER_MACHINE_IP\=$|DOCKER_MACHINE_IP\=$DOCKER_MACHINE_IP|" ./Makefile

sed -i "s|DOCKER_TLS_VERIFY\=; \\\|DOCKER_TLS_VERIFY\=$DOCKER_TLS_VERIFY; \\\|" ./Makefile
sed -i "s|DOCKER_HOST\=; \\\|DOCKER_HOST\=$DOCKER_HOST; \\\|" ./Makefile
sed -i "s|DOCKER_CERT_PATH\=; \\\|DOCKER_CERT_PATH\=$DOCKER_CERT_PATH; \\\|" ./Makefile
sed -i "s|DOCKER_MACHINE_NAME\=; \\\|DOCKER_MACHINE_NAME\=$DOCKER_MACHINE_NAME; \\\|" ./Makefile
sed -i "s|DOCKER_MACHINE_IP\=; \\\|DOCKER_MACHINE_IP\=$DOCKER_MACHINE_IP; \\\|" ./Makefile

# unset env variables for docker
eval $(docker-machine env -u)
