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
    mkdir -p $GERRIT_DATA_DIR/etc $GERRIT_DATA_DIR/git $GERRIT_DATA_DIR/db $GERRIT_DATA_DIR/index $GERRIT_DATA_DIR/cache
    docker run --name=$GERRIT_DOCKER_NAME \
        -v $GERRIT_DATA_DIR/etc:/var/gerrit/etc \
        -v $GERRIT_DATA_DIR/git:/var/gerrit/git \
        -v $GERRIT_DATA_DIR/db:/var/gerrit/db \
        -v $GERRIT_DATA_DIR/index:/var/gerrit/index \
        -v $GERRIT_DATA_DIR/cache:/var/gerrit/cache \
        gerritcodereview/gerrit:2.16.28 || true
    docker stop $GERRIT_DOCKER_NAME
    docker rm   $GERRIT_DOCKER_NAME

    cp files/gerrit.config $GERRIT_DATA_DIR/etc/
    sed -i "s/openldap-server/$OPENLDAP_SERVER/g"  $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/postgresql-server/$POSTGRE_SERVER/g" $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/openldap-password/$ADMIN_PASSWD/g"   $GERRIT_DATA_DIR/etc/gerrit.config
    docker run --name=$GERRIT_DOCKER_NAME \
        -v $GERRIT_DATA_DIR/etc:/var/gerrit/etc \
        -v $GERRIT_DATA_DIR/git:/var/gerrit/git \
        -v $GERRIT_DATA_DIR/db:/var/gerrit/db \
        -v $GERRIT_DATA_DIR/index:/var/gerrit/index \
        -v $GERRIT_DATA_DIR/cache:/var/gerrit/cache \
        gerritcodereview/gerrit:2.16.28 java -jar /var/gerrit/bin/gerrit.war init -d /var/gerrit || true
    docker stop $GERRIT_DOCKER_NAME
    docker rm   $GERRIT_DOCKER_NAME
    ;;
""|start)
    if docker ps -a | grep $GERRIT_DOCKER_NAME; then
        echo "$GERRIT_DOCKER_NAME already running !"
        exit 0
    fi
    sed -i "s/openldap-server/$OPENLDAP_SERVER/g"  $GERRIT_DATA_DIR/etc/gerrit.config
    sed -i "s/postgresql-server/$POSTGRE_SERVER/g" $GERRIT_DATA_DIR/etc/gerrit.config
    docker run -d --rm --name=$GERRIT_DOCKER_NAME \
        -e CANONICAL_WEB_URL=http://$GERRIT_SERVER:8002 -p 8002:8002 -p 29418:29418 \
        -v $GERRIT_DATA_DIR/etc:/var/gerrit/etc \
        -v $GERRIT_DATA_DIR/git:/var/gerrit/git \
        -v $GERRIT_DATA_DIR/db:/var/gerrit/db \
        -v $GERRIT_DATA_DIR/index:/var/gerrit/index \
        -v $GERRIT_DATA_DIR/cache:/var/gerrit/cache \
        gerritcodereview/gerrit:2.16.28
    ;;
stop)
    docker stop $GERRIT_DOCKER_NAME
    docker rm   $GERRIT_DOCKER_NAME 2> /dev/null || true
    ;;
esac

