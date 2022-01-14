#!/bin/bash
kubectl get ns | grep -i 'log' &> /dev/null
if [ $? == 0 ]; then
 echo "ELK Stack already installed"
else
echo "ELK Stack not installed already. Installing EFK  now!"
 #Create namespace
 kubectl create ns watch
 kubectl create ns log
 kubectl create ns db
 # Create ElasticSearch
 helm repo add elastic https://helm.elastic.co
 helm install elasticsearch elastic/elasticsearch -f elasticsearch_elk.yaml --namespace db
 #Kibana
 helm install elasticsearch elastic/kibana -f kibana.yaml --namespace watch
 #logStash
 helm install logstash elastic/logstash -f logstash.yaml --namespace log
 #FileBeat
 kubectl apply -f tools/elk/filebeat.yaml -n log
fi
