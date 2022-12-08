#!/usr/bin/env bash

set -x

# bash /home/jmeter/run.sh
# echo 'bash /opt/jmeter/bin/jmeter -n -t /home/jmeter/1-https.jmx -l /home/csv/jmeter-xxxxxxxxxxxxxx-`date +%Y%m%d`.csv -JcsvFile=/home/jmeter/userlist.csv' > /home/jmeter/run.sh

project=$1
if [[ "${project}" == "" ]]; then
  project=debug
fi
jmx=$8
if [[ "${jmx}" == "" ]]; then
  jmx=1-https.jmx
fi
protocol=$2
if [[ "${protocol}" == "" ]]; then
  protocol=http
fi
serverAddr=$3
if [[ "${serverAddr}" == "" ]]; then
  serverAddr=localhost
fi
serverPort=$4
if [[ "${serverPort}" == "" ]]; then
  serverPort=8080
fi
timeSec=$5
if [[ "${timeSec}" == "" ]]; then
  timeSec=10
fi
loopCnt=$6
if [[ "${loopCnt}" == "" ]]; then
  loopCnt=1
fi
userNumber=$7
if [[ "${userNumber}" == "" ]]; then
  userNumber=10
fi

sourceFile=/home/jmeter/userlist.csv

echo "project: ${project}"
echo "jmx: ${jmx}"
echo "protocol: ${protocol}"
echo "serverAddr: ${serverAddr}"
echo "serverPort: ${serverPort}"
echo "timeSec: ${timeSec}"
echo "loopCnt: ${loopCnt}"
echo "userNumber: ${userNumber}"
echo "sourceFile: ${sourceFile}"

resultFile=xxxxxxxxxxxxxx-${project}-`date +%Y%m%d`.csv
echo "resultFile: ${resultFile}"

if [[ "${project}" == "debug" ]]; then
  kill -9 `ps -ef | grep filebeat | awk '{print $2}' | head -n 1`
  #rm -Rf /Volumes/workspace/tz/filebeat-7.13.2-darwin-x86_64/data/filebeat.lock
  rm -Rf /Volumes/workspace/tz/filebeat-7.13.2-darwin-x86_64/data/registry
  rm -Rf /Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/jmeter/*.csv
  bash /Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/apache-jmeter-5.5/bin/jmeter.sh \
    -n -t /Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/jmeter/${jmx} \
    -l /Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/csv/${resultFile} \
    -JcsvFile=/Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/jmeter/userlist.csv \
    -Jprotocol=${protocol} \
    -JserverAddr=${serverAddr} \
    -JserverPort=${serverPort} \
    -JtimeSec=${timeSec} \
    -JloopCnt=${loopCnt} \
    -JuserNumber=${userNumber} && \
  /Volumes/workspace/tz/filebeat-7.13.2-darwin-x86_64/filebeat run -e -c /Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/docker/filebeat_local.yml
else
  rm -Rf /home/csv/*.csv
  bash /opt/jmeter/bin/jmeter -n -t /home/jmeter/${jmx} -l /home/csv/${resultFile} \
    -JcsvFile=${sourceFile} \
    -Jprotocol=${protocol} \
    -JserverAddr=${serverAddr} \
    -JserverPort=${serverPort} \
    -JtimeSec=${timeSec} \
    -JloopCnt=${loopCnt} \
    -JuserNumber=${userNumber}

#  kill -9 `ps -ef | grep filebeat | awk '{print $2}'`
#  rm -Rf /var/lib/filebeat/filebeat.lock && \
#  rm -Rf /var/lib/filebeat/registry
#  /usr/bin/nohup /usr/bin/filebeat --path.config /etc/filebeat -c /etc/filebeat/filebeat.yml run -e -d "*" 2>&1 &
fi

#sleep 3600

#/usr/share/filebeat/bin/filebeat


