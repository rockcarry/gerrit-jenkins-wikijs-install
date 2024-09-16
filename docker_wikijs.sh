#!/bin/sh

set -e

WIKIJS_DOCKER_NAME=wikijs-server
WIKIJS_DATA_DIR=$PWD/wikijs

if [ "$POSTGRE_SERVER"x = ""x ]; then
    POSTGRE_SERVER=localhost
fi

case "$1" in
""|start)
    if docker ps -a | grep $WIKIJS_DOCKER_NAME; then
        echo "$WIKIJS_DOCKER_NAME already running !"
        exit 0
    fi
    mkdir -p $WIKIJS_DATA_DIR/data
    docker run -d --rm --name=$WIKIJS_DOCKER_NAME \
        -p 8001:3000 \
        -e DB_TYPE=postgres \
        -e DB_HOST=$POSTGRE_SERVER \
        -e DB_PORT=5432 \
        -e DB_USER=wikijs-user \
        -e DB_PASS=wikijs-user \
        -e DB_NAME=wikijs-db \
        ghcr.io/requarks/wiki:2.5
    ;;
stop)
    docker stop $WIKIJS_DOCKER_NAME
    docker rm   $WIKIJS_DOCKER_NAME 2> /dev/null || true
    ;;
esac
