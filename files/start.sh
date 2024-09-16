#!/bin/sh

export JENKINS_HOME=/var/jenkins
mkdir -p $JENKINS_HOME
java -jar -Djsch.client_pubkey=ssh-rsa -Djsch.server_host_key=ssh-rsa /jenkins-2.462.2.war

while true
do
    sleep 1
done
