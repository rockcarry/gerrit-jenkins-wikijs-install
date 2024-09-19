#!/bin/sh

export GERRIT_HOME=/var/gerrit

case "$1" in
install)
    java -jar /gerrit-2.16.28.war init -d $GERRIT_HOME
    exit 0
    ;;
*)
    /$GERRIT_HOME/bin/gerrit.sh start
    ;;
esac

while true
do
    sleep 1
done
