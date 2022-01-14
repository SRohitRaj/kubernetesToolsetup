#!/bin/sh
cat <<EOF | kubectl apply -f - 
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
---
EOF

#add jetstack repo 
helm repo add jetstack https://charts.jetstack.io
helm repo update

#install all custome resource definations 
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.0/cert-manager.crds.yaml

#install helm chart
helm upgrade \
  --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace 



# # delete setup
# helm delete cert-manager -n cert-manager
# kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.3.0/cert-manager.crds.yaml
# kubectl delete ns cert-manager
