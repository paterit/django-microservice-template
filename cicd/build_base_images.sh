#!/bin/bash

# automate pushing new versions of base images
CURR_DIR=`pwd`
# $1 - REPO_DIR
# $2 - REPO_NAME
# $3 - TAG
build_push () {
    TEMP_BUILD_NAME='temp-build-name'

    cd $1 && \
    docker build -t $TEMP_BUILD_NAME .  

    IMAGE_ID=`docker images | awk '$1~/temp-build-name/ {print $3}'`
    docker tag $IMAGE_ID $2:$3
    docker tag $IMAGE_ID $2:latest
    docker push $2:$3
    docker push $2:latest
    docker rmi $TEMP_BUILD_NAME:latest
    cd $CURR_DIR
}

build_push '../../locustio' 'paterit/locustio' '0.9.0-python3.6.6-alpine3.8'
build_push '../../sphinx' 'paterit/sphinx' '1.5.3-python3.6.6-alpine3.8'
build_push '../../node-behave' 'paterit/node-behave' '10.2-behave1.2.5-python3.6.5-alpine3.8'
build_push '../../django-postgresql-alpine' 'paterit/django-postgresql-alpine' '2.1.2-python3.6.6-node3.8'
build_push '../../buildbot-worker-docker' 'paterit/buildbot-worker-docker' '1.1.0-docker18.06.1'
