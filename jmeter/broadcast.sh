#!/usr/bin/env bash

#set -x
# bash /home/jmeter/broadcast.sh

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

echo "project: ${project}"
echo "jmx: ${jmx}"
echo "protocol: ${protocol}"
echo "serverAddr: ${serverAddr}"
echo "serverPort: ${serverPort}"
echo "timeSec: ${timeSec}"
echo "loopCnt: ${loopCnt}"
echo "userNumber: ${userNumber}"

params="project=${project}&protocol=${protocol}&serverAddr=${serverAddr}&serverPort=${serverPort}&timeSec=${timeSec}&loopCnt=${loopCnt}&userNumber=${userNumber}&jmx=${jmx}"
echo "==params: ${params}"
echo "curl http://localhost:8000/jmeter?${params}"

#PODS=(10.70.2.60 10.70.2.17)
PODS=(`kubectl -n devops --kubeconfig /root/.kube/ekscluster get pods -l app=devops-jmeter -o jsonpath='{.items[*].status.podIP}'`)
for item in "${PODS[@]}"; do
  echo "===================================="
  echo "curl http://${item}:8000/jmeter?${params}"
  curl "http://${item}:8000/jmeter?${params}" &
  echo "===================================="
done

#sleep 3600

exit 0

kubectl -n devops get pods -l app=devops-jmeter | awk '{print $1}'

--kubeconfig /root/.kube/ekscluster

PODS=(`kubectl -n devops get pods -l app=devops-jmeter | awk '{print $1}'`)
for item in "${PODS[@]}"; do
  echo "====================================${item}"
  if [[ "${item}" != "NAME" ]]; then
#    echo "/usr/bin/nohup kubectl -n devops exec -it pod/${item} -- bash /home/jmeter/import.sh 2>&1 &"
#    /usr/bin/nohup kubectl -n devops exec -it pod/${item} -- bash /home/jmeter/import.sh 2>&1 &
    echo "kubectl -n devops exec -it pod/${item} -- bash /home/jmeter/import.sh"
    kubectl -n devops exec -it pod/${item} -- bash -c "/home/jmeter/import.sh"
    echo "===================================="
  fi
done


PODS=(`kubectl -n devops get pods -l app=devops-jmeter | awk '{print $1}'`)
for item in "${PODS[@]}"; do
  if [[ "${item}" != "NAME" ]]; then
    kubectl -n devops exec -it pod/${item} -- bash -c "cat /home/csv/xxxxxxxxxxxxxx-debug1-20221205.csv | wc -l"
  fi
done




rm *
PODS=(`kubectl --kubeconfig /root/.kube/ekscluster -n devops get pods -l app=devops-jmeter | awk '{print $1}'`)
for item in "${PODS[@]}"; do
  if [[ "${item}" != "NAME" ]]; then
    kubectl --kubeconfig /root/.kube/ekscluster -n devops cp ${item}:/home/csv/xxxxxxxxxxxxxx-debug1-20221205.csv ${item}.csv
  fi
done
tar cvfz csv.tar *.csv

kubectl -n devops cp devops-jmeter-556f7f88f5-4rp49:/home/tmp/csv.tar csv.tar

head -n 1 `ls *.csv | head -n 1` > merged.csv
CSVS=(`ls *.csv`)
for item in "${CSVS[@]}"; do
  tail -n +2 ${item} >> merged.csv
done


JMeterPluginsCMD --generate-png responsetimes.png --input-jtl your_merged_file.csv --plugin-type ResponseTimesOverTime

https://stackoverflow.com/questions/54439263/merge-results-plugin-jmeter-on-non-gui-mode
PluginsManagerCMD --tool Reporter --generate-csv merged.csv \
  --input-jtl merge-results.properties --plugin-type MergeResults

/Volumes/workspace/tz/tz-devops-utils/projects/tz-devops-jmeter/apache-jmeter-5.5/bin/reportgenerator.properties

