#!/bin/sh

set -e 

case "$1" in
""|start)
    ./docker_openldap.sh
    ./docker_postgres.sh
    ./docker_ldappasswd.sh
    ./docker_pgadmin.sh
    ./docker_sonarqube.sh
    ./docker_wikijs.sh
    ./docker_jenkins.sh
    ./docker_gerrit.sh
    ;;
stop)
    ./docker_gerrit.sh     stop || true
    ./docker_jenkins.sh    stop || true
    ./docker_wikijs.sh     stop || true
    ./docker_sonarqube.sh  stop || true
    ./docker_pgadmin.sh    stop || true
    ./docker_ldappasswd.sh stop || true
    ./docker_postgres.sh   stop || true
    ./docker_openldap.sh   stop || true
    ;;
install)
    ./docker_gerrit.sh install
    ;;
esac
