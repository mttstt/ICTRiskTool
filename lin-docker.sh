#!/bin/bash
#
# Use: lin-docker.sh [command] [Password] [Docker-Hub release]
# Put ICTRiskTool in a Docker architecture
#
#./lin-docker.sh -u [Password Active Directory] [Docker-Hub release]
#./lin-dcoker.sh -b [Docker-Hub release]
#./lin-dcoker.sh -p [Password Docker-Hub]
#./lin-dcoker.sh -m [Password Active Directory]
#
# Possible commands:
#
# -h, --help        Help
# -m, --meteor      Launch meteor, without Docker, for testing [Password Active Directory]
# -b, --build       Build ICTRiskTool docker image [New Docker-Hub release]
# -p, --push        Push ICTRiskTool image to Docker Hub [Password Docker Hub] [Docker release]
# -u, --dockerup    Docker-compose up [Password Active Directory] [Docker release]
# -d, --delete      Delete all (containers, images, volumes, networks)
# -s, --stop	    docker-compose stop, useful when containers are started like service/ademon
#
# Useful command for ubuntu 17: newgrp docker
#
# Useful command for bash to containet:  docker exec -ti <container> bash

while [[ $# -gt 0 ]]
do
key="$1"
passwd="$2"
release="$3"
statusJreport=`curl -s --head http://localhost:5488 | head -n 1 | grep "HTTP/1.[01] [23].."`

case $key in
    -d|--delete)
        echo "Delete All"
        echo "Ferma tutti i containers"
        docker-compose down
        echo "Elimina tutti i containers"
        docker rm $(docker container ls -a -q) -f
        echo "Elimina tutti i volumi"
        docker volume prune -f
        echo "Elimina tutte le immagini"
        docker rmi $(docker images -a -q)
    shift # past argument
    shift # past argument
    ;;

    -b|--build)
        echo "build"
#       cd ~/AuditTool
        if [ ! -f ~/ICTRiskTool/.gitignore ]; then
            echo ".gitignore not found!"
        else
            rm .gitignore
	fi
        rm -rf .git
        rm -fR ICTRiskTool
        wget http://www.meteorkitchen.com/api/getapp/json/8R7NFyfzjb7Xt4EBL -O AuditTool.json
        meteor-kitchen ICTRiskTool.json ICTRiskTool
        cd ICTRiskTool
	cp ../docker/Dockerfile .
	cp ../docker/.dockerignore .

	export TAG=$passwd && docker-compose -f ../docker/docker-compose-dev.yml build --force-rm --no-cache
    shift # past argument
    shift # past argument
    exit 1
    ;;

    -m|--meteor)
        echo "meteor"
#	cd ~/AuditTool
	if [ -z "$statusJreport" ]; then
                echo 'Jsreport not installed: no pdf reports !' >&2
        else
                echo 'Jsreport found !'
        fi

        if [ ! -f ~/ICTRiskTool/.gitignore ]; then
                echo ".gitignore not found!"
        else
            rm .gitignore
        fi
        rm -rf .git
        rm -fR ICTRiskTool
        wget http://www.meteorkitchen.com/api/getapp/json/8R7NFyfzjb7Xt4EBL -O AuditTool.json
        meteor-kitchen ICTRiskTool.json ICTRiskTool
        cd ICTRiskTool
        meteor
    shift # past argument
    shift # past argument
    ;;

    -p|--push)
        echo "Push image to Docker Hub"
        docker login -password $passwd -username mttstt
        docker push mttstt/ictrisktool
    shift # past argument
    shift # past argument
    ;;

    -u|--dockerup)
        echo "Docker up like a service (-d)"
        export TAG=$release && export passwdAD=$passwd && docker-compose -f docker/docker-compose.yml up -d
	exit 1
    shift # past argument
    shift # past argument
    ;;

    -s|--stop)
        echo "Stopping AuditTool container daemon"
        docker-compose -f docker/docker-compose.yml stop
    shift # past argument
    shift # past argument
    ;;

    -b|--bye)
    echo "bye"
    echo "bye"
    shift # past argument
    shift # past argument
    ;;

    *)    # unknown option

        echo "Use: lin-docker.sh [command] [Password] [Docker HUB release]"
        echo "Put ICTRiskTool in a Docker architecture"
        echo ""
        echo "./lin-docker.sh -u [Password Active Directory] [Docker-Hub release]"
        echo "./lin-dcoker.sh -b [New Docker-Hub release]"
        echo "./lin-dcoker.sh -p [Password Docker-Hub]"
        echo ""
        echo "Possible commands:"
        echo ""
        echo "-h, --help        Help"
        echo "-m, --meteor      Launch meteor, without Docker (for testing) [Password Active Directory]"
        echo "-b, --build       Build ICTRiskTool docker image [New Docker-Hub release]"
        echo "-p, --push        Push ICTRiskTool image to Docker Hub [Password Docker Hub] [Docker-Hub release]"
        echo "-u, --dockerup    Docker-compose up [Password Active Directory] [DockerHub release]"
        echo "-d, --delete      Delete all (containers, images, volumes, networks)"
        echo "-s, --stop        Stop ICTRiskTool container daemon"

    shift # past argument# Options:
    ;;

esac
done
