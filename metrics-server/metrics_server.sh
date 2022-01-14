#!/bin/bash
echo "Installing Metrics server"
kubectl apply -f tools/metrics-server/metrics_server.yaml
