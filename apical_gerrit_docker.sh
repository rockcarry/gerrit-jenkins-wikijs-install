#!/bin/sh

DOCKER_IMAGE_NAME="apical/gerrit:v1.0.1"

function docker_create()
{
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep $DOCKER_IMAGE_NAME; then
        echo "docker image $DOCKER_IMAGE_NAME already exists !"
        return
    fi

    rm -rf $PWD/docker_temp
    mkdir $PWD/docker_temp
    cp $PWD/files/gerrit-2.16.28.war $PWD/docker_temp
    cp $PWD/files/gerrit.sh          $PWD/docker_temp
    cd $PWD/docker_temp

    echo "FROM ubuntu:20.04"                    > Dockerfile
    echo "ENV LESSCHARSET=utf-8"               >> Dockerfile
    echo "ENV LANG=C.UTF-8"                    >> Dockerfile
    echo "ENV TZ=Asia/Shanghai"                >> Dockerfile
    echo "RUN ln -snf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone" >> Dockerfile
    echo "RUN apt-get update" >> Dockerfile
    echo "RUN apt-get install -y git openjdk-11-jre-headless" >> Dockerfile
    echo "RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*" >> Dockerfile
    echo "COPY gerrit-2.16.28.war /"           >> Dockerfile
    echo "COPY gerrit.sh /usr/local/bin"       >> Dockerfile
    echo "RUN groupadd -g 1000 gerrit"         >> Dockerfile
    echo "RUN useradd -u 1000 -g 1000 gerrit"  >> Dockerfile
    echo "RUN mkdir -p /home/gerrit"           >> Dockerfile
    echo "RUN chown gerrit:gerrit /home/gerrit">> Dockerfile
    echo "USER gerrit"                         >> Dockerfile
    echo "CMD [\"/usr/local/bin/gerrit.sh\"]"  >> Dockerfile

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
    docker run -d  --rm -p 8002:8080 $DOCKER_IMAGE_NAME
    ;;
esac

