#!/bin/sh

set -e

PGADMIN_DOCKER_NAME=pgadmin
PGADMIN_DATA_DIR=$PWD/pgadmin

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

case "$1" in
""|start)
    if docker ps -a | grep $PGADMIN_DOCKER_NAME; then
        echo "$PGADMIN_DOCKER_NAME already running !"
        exit 0
    fi
    docker run -d --rm --name=$PGADMIN_DOCKER_NAME \
        -p 8000:80 \
        -e PGADMIN_DEFAULT_EMAIL=admin@apical.com.cn \
        -e PGADMIN_DEFAULT_PASSWORD=$ADMIN_PASSWD \
        dpage/pgadmin4
    ;;
stop)
    docker stop $PGADMIN_DOCKER_NAME
    docker rm   $PGADMIN_DOCKER_NAME 2> /dev/null || true
    ;;
esac
