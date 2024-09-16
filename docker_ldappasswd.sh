#!/bin/sh

set -e

LDAPPASSWD_DOCKER_NAME=ldappasswd
LDAPPASSWD_DATA_DIR=$PWD/ldappasswd

if [ "$OPENLDAP_SERVER"x = ""x ]; then
    OPENLDAP_SERVER=localhost
fi

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

case "$1" in
""|start)
    if docker ps -a | grep $LDAPPASSWD_DOCKER_NAME; then
        echo "$LDAPPASSWD_DOCKER_NAME already running !"
        exit 0
    fi
    mkdir -p $LDAPPASSWD_DATA_DIR/ssp $LDAPPASSWD_DATA_DIR/logs
    docker run -d --rm --name=$LDAPPASSWD_DOCKER_NAME -p 8005:80 \
        -e LDAP_SERVER=ldap://$OPENLDAP_SERVER \
        -e LDAP_BINDDN=cn=admin,dc=apical,dc=com,dc=cn \
        -e LDAP_BINDPASS=$ADMIN_PASSWD \
        -e LDAP_BASE_SEARCH=ou=users,dc=apical,dc=com,dc=cn \
        -v /etc/localtime:/etc/localtime \
        -v $LDAPPASSWD_DATA_DIR/ssp:/www/ssp \
        -v $LDAPPASSWD_DATA_DIR/logs:/www/logs \
        tiredofit/self-service-password:latest
    ;;
stop)
    docker stop $LDAPPASSWD_DOCKER_NAME
    docker rm   $LDAPPASSWD_DOCKER_NAME 2> /dev/null || true
    ;;
esac
