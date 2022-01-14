#!/bin/bash
echo "Creating Kubernetes Dashboard"
kubectl apply -f tools/dashboard/dashboard_recommended.yaml
kubectl apply -f tools/dashboard/dashboard_ingress.yaml
