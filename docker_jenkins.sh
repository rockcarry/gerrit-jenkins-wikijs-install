#!/bin/sh

set -e

JENKINS_DOCKER_NAME=jenkins-server
JENKINS_DATA_DIR=$PWD/jenkins

case "$1" in
""|start)
    if docker ps -a | grep $JENKINS_DOCKER_NAME; then
        echo "$JENKINS_DOCKER_NAME already running !"
        exit 0
    fi
    mkdir -p $JENKINS_DATA_DIR
    docker run -d --rm --name=$JENKINS_DOCKER_NAME \
        -u 1000:1000 -p 8003:8080 -p 50000:50000 \
        -v $JENKINS_DATA_DIR:/var/jenkins \
        apical/jenkins:v1.0.1
    ;;
stop)
    docker stop $JENKINS_DOCKER_NAME
    docker rm   $JENKINS_DOCKER_NAME 2> /dev/null || true
    ;;
esac
