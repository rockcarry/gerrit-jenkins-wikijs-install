#!/bin/sh

set -e

GERRIT_DOCKER_NAME=gerrit-server
GERRIT_DATA_DIR=$PWD/gerrit

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

if [ "$OPENLDAP_SERVER"x = ""x ]; then
    OPENLDAP_SERVER=localhost
fi

if [ "$POSTGRE_SERVER"x = ""x ]; then
    POSTGRE_SERVER=localhost
fi

if [ "$GERRIT_SERVER"x = ""x ]; then
    GERRIT_SERVER=localhost
fi

case "$1" in
install)
    mkdir -p $GERRIT_DATA_DIR/etc/
    cp files/gerrit.config $GERRIT_DATA_DIR/etc/
    sed -i "s/openldap-server/$OPENLDAP_SERVER/g"  $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/postgresql-server/$POSTGRE_SERVER/g" $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/openldap-password/$ADMIN_PASSWD/g"   $GERRIT_DATA_DIR/etc/gerrit.config
    docker run -it --rm --name=$GERRIT_DOCKER_NAME \
        -v $GERRIT_DATA_DIR:/var/gerrit \
        apical/gerrit:v1.0.1 gerrit.sh install
    docker stop $GERRIT_DOCKER_NAME
    ;;
""|start)
    if docker ps -a | grep $GERRIT_DOCKER_NAME; then
        echo "$GERRIT_DOCKER_NAME already running !"
        exit 0
    fi
    sed -i "s/openldap-server/$OPENLDAP_SERVER/g"  $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/postgresql-server/$POSTGRE_SERVER/g" $GERRIT_DATA_DIR/etc/gerrit.config
    docker run -d --rm --name=$GERRIT_DOCKER_NAME \
        -p 8002:8002 -p 29418:29418 \
        -e CANONICAL_WEB_URL=http://$GERRIT_SERVER:8002 \
        -v $GERRIT_DATA_DIR:/var/gerrit \
        apical/gerrit:v1.0.1
    ;;
stop)
    docker stop $GERRIT_DOCKER_NAME
    docker rm   $GERRIT_DOCKER_NAME 2> /dev/null || true
    ;;
esac

