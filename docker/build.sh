#!/usr/bin/env bash

set -x

#bash build.sh latest
#bash build.sh debug2
#apt install docker-compose -y

#bash /vagrant/projects/tz-devops-jmeter/build.sh debug3

TZ_PROJECT=tz-devops-jmeter
cd /vagrant/projects/${TZ_PROJECT}/docker

VERSION='latest'
if [[ "$1" != "" ]]; then
  VERSION=$1
fi

cp -Rf docker-compose.yml docker-compose.yml_bak
docker-compose -f docker-compose.yml_bak build
#docker-compose -f docker-compose.yml_bak build --no-cache
docker image ls
docker-compose -f docker-compose.yml_bak up -d
#docker-compose -f docker-compose.yml_bak down
docker exec -it `docker ps | grep ${TZ_PROJECT} | awk '{print $1}'` bash

exit 0


curl -XGET http://localhost:8000/health
curl -XGET http://localhost:8000/jmeter?project=debug1
curl -XGET http://localhost:8000/filebeat?project=debug&cmd=run

filebeat run -e
#RUN filebeat run -e -d "*"
