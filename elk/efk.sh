#!/bin/bash
kubectl get ns | grep -i 'efk' &> /dev/null
if [ $? == 0 ]; then                                                                                                                                          echo "EFK Stack already installed"
else                                                                                                                                                         echo "EFK Stack not installed already. Installing EFK  now!"
  kubectl create namespace efk
  helm repo add elastic https://helm.elastic.co
  helm install elasticsearch elastic/elasticsearch \
          --version=7.9.0 \
          --namespace=efk \
          -f elastic-values.yaml
  # Install FluentD
  helm repo add fluent https://fluent.github.io/helm-charts
  helm install fluent-bit fluent/fluent-bit \
            --version 0.6.3 \
            --namespace=efk
  # Install Kibana
  helm install kibana elastic/kibana \
            --version=7.9.0 \
            --namespace=efk \
            --set service.type=NodePort \
            --set service.nodePort=31000
fi
