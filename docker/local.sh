#!/usr/bin/env bash

cd /vagrant/projects/tz-jmeter-k8s

brew install python
brew info python

#sudo /usr/local/Cellar/python@3.9/3.9.1/bin/easy_install-3.9 virtualenv
virtualenv venv --python=python3.9
virtualenv venv
source venv/bin/activate
python --version

#pip3 freeze > requirements.txt
pip3 install --upgrade -r requirements.txt

#pip install pytest

exit 0




# make docker image
cd tz-k8s-vagrant/projects/tz-jmeter-k8s
#vi Dockerfile
#CMD [ "python", "/home/app/server.py" ]
#sudo chown -Rf vagrant:vagrant /var/run/docker.sock
#docker login -u="$USERNAME" -p="$PASSWD"
#docker rmi tz-jmeter-k8s -f
#docker build -t tz-jmeter-k8s .
#docker image ls
#docker tag tz-jmeter-k8s:latest topzone/tz-jmeter-k8s:latest
#docker push topzone/tz-jmeter-k8s:latest

docker run -p 8000:8000 tz-jmeter-k8s

docker run -d -v `pwd`:/home -p 8000:8000 tz-jmeter-k8s
#docker ps
#docker exec -it a7757a1e1c99 /bin/bash

curl -X GET http://localhost:8000/health

#docker image ls
#docker container run -it --rm --name=debug2 -v `pwd`:/home -p 8000:8000 cd0dad6e335a /bin/sh
docker run --rm -it --name=debug2 -v `pwd`:/home -p 8000:8000 366853331b20  /bin/sh

#python /home/app/server.py &
#cat /home/ioNng23DkIM.csv
