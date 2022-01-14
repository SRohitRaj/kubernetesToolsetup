#!/bin/bash
echo "Installing HPA"
#Install Litmus Chaos Operator
kubectl apply -f tools/hpa/hpa.yaml
kubectl apply -f tools/hpa/hpa_deployment.yaml
