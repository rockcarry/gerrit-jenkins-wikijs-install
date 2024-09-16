#!/bin/sh

set -e

POSTGRES_DOCKER_NAME=postgres-server
POSTGRES_DATA_DIR=$PWD/postgres

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

case "$1" in
""|start)
    if docker ps -a | grep $POSTGRES_DOCKER_NAME; then
        echo "$POSTGRES_DOCKER_NAME already running !"
        exit 0
    fi
    mkdir -p $POSTGRES_DATA_DIR/data
    docker run -d --rm --name=$POSTGRES_DOCKER_NAME -u 1000:1000 -p 5432:5432 \
        -e POSTGRES_USER=admin \
        -e POSTGRES_PASSWORD=$ADMIN_PASSWD \
        -v $POSTGRES_DATA_DIR/data:/var/lib/postgresql/data \
        postgres:15.8
    ;;
stop)
    docker stop $POSTGRES_DOCKER_NAME
    docker rm   $POSTGRES_DOCKER_NAME 2> /dev/null || true
    ;;
esac

#
# 创建数据库 gerrit-db
# 创建用户 gerrit-user 密码 gerrit-user
#
# 创建数据库 wikijs-db
# 创建用户 wikijs-user 密码 wikijs-user
#
# 创建数据库 sonarqube-db
# 创建用户 sonarqube-user 密码 sonarqube-user
#
