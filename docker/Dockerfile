FROM xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-2.amazonaws.com/tz-jmeter-base:latest
# FROM python:3.8

COPY . /home
WORKDIR /home

# open 4445 port to target

RUN mkdir /root/.aws
RUN mkdir /root/.kube
COPY config /root/.aws/config
COPY credentials /root/.aws/credentials
COPY eks-main* /root/.kube/

COPY docker/filebeat.yml /etc/filebeat/filebeat.yml
RUN chown root:root /etc/filebeat/filebeat.yml && \
    rm -Rf /var/lib/filebeat/filebeat.lock && \
    rm -Rf /var/lib/filebeat/registry

RUN mkdir -p /home/csv

#filebeat run -e
#RUN filebeat run -e -d "*"

RUN pip3 install -r requirements.txt

#CMD [ "python", "app/server.py"]

RUN chmod +x /home/jmeter/server.sh
ENTRYPOINT ["sh","/home/jmeter/server.sh"]
EXPOSE 8000

