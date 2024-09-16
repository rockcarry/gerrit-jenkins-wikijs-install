#!/bin/sh

set -e

SONARQUBE_DOCKER_NAME=sonarqube-server
SONARQUBE_DATA_DIR=$PWD/sonarqube

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

if [ "$POSTGRE_SERVER"x = ""x ]; then
    POSTGRE_SERVER=localhost
fi

case "$1" in
""|start)
    if docker ps -a | grep $SONARQUBE_DOCKER_NAME; then
        echo "$SONARQUBE_DOCKER_NAME already running !"
        exit 0
    fi
    sudo sysctl -w vm.max_map_count=262144
    mkdir -p $SONARQUBE_DATA_DIR/data $SONARQUBE_DATA_DIR/extensions $SONARQUBE_DATA_DIR/bundled-plugins $SONARQUBE_DATA_DIR/pdf-files $SONARQUBE_DATA_DIR/conf $SONARQUBE_DATA_DIR/logs
    docker run -d --rm --name=$SONARQUBE_DOCKER_NAME -p 8006:9000 \
        -e SONAR_JDBC_URL=jdbc:postgresql://$POSTGRE_SERVER:5432/sonarqube-db \
        -e SONAR_JDBC_USERNAME=sonarqube-user \
        -e SONAR_JDBC_PASSWORD=sonarqube-user \
        -v $SONARQUBE_DATA_DIR/data:/opt/sonarqube/data \
        -v $SONARQUBE_DATA_DIR/extensions:/opt/sonarqube/extensions \
        -v $SONARQUBE_DATA_DIR/bundled-plugins:/opt/sonarqube/bundled-plugins \
        -v $SONARQUBE_DATA_DIR/pdf-files:/opt/sonarqube/pdf-files \
        -v $SONARQUBE_DATA_DIR/conf:/opt/sonarqube/conf \
        -v $SONARQUBE_DATA_DIR/logs:/opt/sonarqube/logs \
        sonarqube:9.9.6-community
    ;;
stop)
    docker stop $SONARQUBE_DOCKER_NAME
    docker rm   $SONARQUBE_DOCKER_NAME 2> /dev/null || true
    ;;
esac
