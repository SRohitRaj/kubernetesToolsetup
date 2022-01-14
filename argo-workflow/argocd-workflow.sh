#!/bin/bash
kubectl get ns | grep -x "argo" &> /dev/null
if [ $? == 0 ]; then
   echo "ArgoCD Workflow already installed"
else 
   kubectl create ns argo
   kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml
   kubectl patch svc argo-server -n argo -p '{"spec": {"type": "LoadBalancer"}}'
fi
