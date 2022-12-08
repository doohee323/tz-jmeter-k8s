#!/usr/bin/env bash

set -x

GIT_BRANCH=$1
STAGING=$2

export GIT_BRANCH=$(echo ${GIT_BRANCH} | sed 's/\//-/g')
GIT_BRANCH=$(echo ${GIT_BRANCH} | cut -b1-21)

bash /var/lib/jenkins/vault.sh get devops-prod tz-devops-jmeter resources
tar xvfz resources.zip && rm -Rf resources.zip

cp -Rf resources/config config
cp -Rf resources/credentials credentials
cp -Rf resources/tz_ekscluster ekscluster

exit 0

- push
#export vault_token=xxx
#cd /vagrant/projects/tz-devops-jmeter
#bash /vagrant/tz-local/docker/vault.sh put devops-prod tz-devops-jmeter resources

- get
bash /var/lib/jenkins/vault.sh get devops-prod tz-devops-jmeter resources
tar xvfz resources.zip && rm -Rf resources.zip
