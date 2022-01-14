#!/bin/bash
kubectl get ns | grep -i 'ingress-nginx' &> /dev/null
if [ $? == 0 ]; then
   echo "Ingress Controller already installed"
else
   echo "Ingress Controller is not installed. Installing Ingress Controller now!"
   #Install ArgoCD
   kubectl apply -f tools/ingress-controller/nginx-ingress-controller.yaml
fi
