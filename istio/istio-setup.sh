#!/bin/bash
kubectl get ns | grep -i 'istio-system' &> /dev/null
if [ $? == 0 ]; then
   echo "Istio setup  already installed"
#1. Download Istio package on local computer
else
   echo "Performing Istio Setup"
   kubectl create ns istio-system
   curl -L https://istio.io/downloadIstio | sh -
   cd istio-1.10.0/
   export PATH=$PWD/bin:$PATH
   istioctl install --set profile=demo -y
   #2.   Setup env variable
   export PATH="$PATH:$HOME/.istioctl/bin"

   #3. Install istio
   istioctl install -y

   #4. Label Nodes
   kubectl label ns default istio-injection=enabled
   kubectl get ns default --show-labels

   #5. Deploy Istio add-on  components

   #Grafana
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/grafana.yaml

   #Prometheus
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/prometheus.yaml

   #Kiali
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/kiali.yaml
   kubectl patch svc  kiali -n istio-system --patch  '{"spec": {"type": "LoadBalancer"}}'

   #Jaeger
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/jaeger.yaml

   #Check services
   kubectl get pods -n istio-system
fi
