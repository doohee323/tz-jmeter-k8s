FROM ubuntu:20.04
# FROM python:3.8

ARG DEBIAN_FRONTEND=noninteractive

COPY . /home
WORKDIR /home

RUN apt-get update && \
    apt-get install -y curl wget build-essential iputils-ping telnet netcat tzdata

RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get install -y python3.8 python3.8-dev python3.8-distutils
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
RUN update-alternatives --set python /usr/bin/python3.8
RUN curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
   python get-pip.py --force-reinstall && \
   rm get-pip.py
RUN apt-get install -y vim unzip xvfb libxi6 libgconf-2-4 rsync openjdk-11-jdk jq

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install --update

RUN curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 && \
    chmod +x aws-iam-authenticator && \
    mv aws-iam-authenticator /usr/local/bin

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl && \
    chmod 777 kubectl && \
    mv kubectl /usr/bin/kubectl

# Install jmeter
RUN wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.4.3.zip && \
    unzip apache-jmeter-5.4.3.zip && \
    mv apache-jmeter-5.4.3 /opt/jmeter
# Install plug-in
RUN cd /opt/jmeter/lib && \
    curl -O https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2.1/cmdrunner-2.2.1.jar && \
    cd ext/ && \
    curl -O https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.8/jmeter-plugins-manager-1.8.jar && \
    cd .. && \
    java  -jar cmdrunner-2.2.1.jar --tool org.jmeterplugins.repository.PluginManagerCMD install-all-except jpgc-hadoop,jpgc-oauth,ulp-jmeter-autocorrelator-plugin,ulp-jmeter-videostreaming-plugin,ulp-jmeter-gwt-plugin,tilln-iso8583

## Install Chrome for Selenium
#RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /chrome.deb
#RUN dpkg -i /chrome.deb || apt-get install -yf
#RUN rm /chrome.deb
#
## Install chromedriver for Selenium
#RUN curl https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip -o chromedriver_linux64.zip
#RUN unzip chromedriver_linux64.zip
#RUN mv chromedriver /usr/local/bin/chromedriver
#RUN chmod +x /usr/local/bin/chromedriver

# Filebeat
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.13.2-amd64.deb && \
    dpkg -i filebeat-7.13.2-amd64.deb && \
    filebeat modules list && \
    filebeat modules enable system nginx mysql logstash && \
    filebeat modules disable system nginx mysql logstash
