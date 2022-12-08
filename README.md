# tz-devops-jmeter

## Run Jmeter in K8S

It's an example env. for running Jmeter in K8S. 
For example, you can run 1000 users' predefined events by Jmeter on 100 ubuntu pods.
And the results of Jmeter CLI can be aggregated into ES. 
If you don't use ES, you need to gather the result files(csv) from the each of ubuntu pos in K8S.

### Env)
```
    - load generator(Jmeter on ubuntu)
        Jmeter CLI => csv
        filebeat => elasticsearch
    - Target System
    - aggregation of results: elasticsearch

    load generator
        - Deploy multiple ubuntu pods in K8S
        - admin page:
            1) Define target url and run
            2) request broadcast load 
                call api to each ubuntu pods
                    run Jmeter CLI on each ubuntu pods
        - send the result to ES by filebeat
```

### Steps)
```
    0. prepare index in ES with pipeline.yml
    0. prepare target system
    1. Deploy tz-jmeter-k8s in K8S
        k8s/Jenkinsfile
    2. open admin page
        http://jmeter.devops.${CLUSTER_NAME}.${DOMAIN_NAME}
    3. Define target url and run
    4. Get the result in ES 
```

### Main Files)
- run.sh
```
  bash /opt/jmeter/bin/jmeter -n -t /home/jmeter/${jmx} -l /home/csv/${resultFile} \
    -JcsvFile=${sourceFile} \
    -Jprotocol=${protocol} \
    -JserverAddr=${serverAddr} \
    -JserverPort=${serverPort} \
    -JtimeSec=${timeSec} \
    -JloopCnt=${loopCnt} \
    -JuserNumber=${userNumber}
```

- Jmeter DockerFile
```
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

# Filebeat
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.13.2-amd64.deb && \
    dpkg -i filebeat-7.13.2-amd64.deb && \
    filebeat modules list && \
    filebeat modules enable system nginx mysql logstash && \
    filebeat modules disable system nginx mysql logstash

# kubectl
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
```

- Filebeat yaml
```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /home/csv/*-*-*.csv
filebeat.config.modules:
  path: /etc/filebeat/modules.d/*.yml
  reload.enabled: false
setup.template:
  enabled: false
  settings:
    index.number_of_shards: 2
setup.kibana:
  host: "kibana.xxx.com"

output.elasticsearch:
  protocol: https
  ssl.verification_mode: none
  hosts: ["es1.elk.eks-main-p.xxx.com:443"]
  username: 'elastic'
  password: 'xxx'
  pipeline: jmeter
  index: "jmeter-%{[dissect.account]}-%{[dissect.yyyymmdd]}"

processors:
  - decode_csv_fields:
      fields:
        message: decoded.csv
      separator: ","
      ignore_missing: false
      overwrite_keys: true
      trim_leading_space: false
      fail_on_error: true

  - dissect:
      field: log.file.path
      tokenizer: "/home/csv/%{account}-%{project}-%{yyyymmdd}.csv"

  - timestamp:
      field: timeStamp
      layouts:
        - '2006-01-02T15:04:05Z'
        - '2006-01-02T15:04:05.999Z'
        - '2006-01-02T15:04:05.999-07:00'
      test:
        - '2019-06-22T16:33:51Z'
        - '2019-11-18T04:59:51.123Z'
        - '2020-08-03T07:10:20.123456+02:00'
```