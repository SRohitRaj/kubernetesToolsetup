#!/bin/bash
kubectl get ns | grep -i 'kubecost' &> /dev/null
if [ $? == 0 ]; then
   echo "kubecost already installed"
else
   echo "kubecost not installed already. Installing Kubecost now!"
   echo "Installing KubeCost"

   kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=testuser

   kubectl create clusterrolebinding cluster-self-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:default

   kubectl create namespace kubecost
   helm repo add kubecost https://kubecost.github.io/cost-analyzer/
   helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken=$KUBECOST --set service.type=ClusterIP --set prometheus.nodeExporter.enabled=false --set prometheus.serviceAccounts.nodeExporter.create=false
   cd $HOME/tools/kubecost
   kubectl apply -f ingress.yaml
fi
