#!/bin/sh

DOCKER_IMAGE_NAME="apical/jenkins:v1.0.2"

function docker_create()
{
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep $DOCKER_IMAGE_NAME; then
        echo "docker image $DOCKER_IMAGE_NAME already exists !"
        return
    fi

    rm -rf $PWD/docker_temp
    mkdir $PWD/docker_temp
    cp $PWD/files/jenkins-2.462.2.war $PWD/docker_temp
    cp $PWD/files/jenkins.sh          $PWD/docker_temp
    cd $PWD/docker_temp

    echo "FROM ubuntu:20.04"                    > Dockerfile
    echo "ENV LESSCHARSET=utf-8"               >> Dockerfile
    echo "ENV LANG=C.UTF-8"                    >> Dockerfile
    echo "ENV TZ=Asia/Shanghai"                >> Dockerfile
    echo "RUN ln -snf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone" >> Dockerfile
    echo "RUN apt-get update" >> Dockerfile
    echo "RUN apt-get install -y curl wget openjdk-17-jre-headless net-tools" >> Dockerfile
    echo "RUN apt-get install -y libc6-dev-i386 libncurses5-dev liblz4-tool vim git python build-essential libtool pkg-config autoconf automake bison flex bc mtd-utils squashfs-tools tclsh" >> Dockerfile
    echo "RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*" >> Dockerfile
    echo "COPY jenkins-2.462.2.war /"             >> Dockerfile
    echo "COPY jenkins.sh /usr/local/bin"         >> Dockerfile
    echo "RUN groupadd -g 1000 jenkins"           >> Dockerfile
    echo "RUN useradd -u 1000 -g 1000 jenkins"    >> Dockerfile
    echo "RUN mkdir -p /home/jenkins"             >> Dockerfile
    echo "RUN chown jenkins:jenkins /home/jenkins">> Dockerfile
    echo "USER jenkins"                           >> Dockerfile
    echo "CMD [\"/usr/local/bin/jenkins.sh\"]"    >> Dockerfile

    docker build -t $DOCKER_IMAGE_NAME .
    cd -
    rm -rf $PWD/docker_temp
}

case "$1" in
create)
    docker_create
    ;;
debug)
    docker run -it --rm -p 8080:8080 $DOCKER_IMAGE_NAME bash
    ;;
""|run)
    docker run -d  --rm -p 8003:8080 $DOCKER_IMAGE_NAME
    ;;
esac

