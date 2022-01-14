#!/bin/sh
echo $ARGOCD_HOST
cat <<EOF | kubectl apply -f - 
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    ingress.kubernetes.io/proxy-body-size: 100M
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/app-root: "/"
spec:
  rules:
  - host: argocd.letsdevops.tk
    http:
      paths:
      - path: /
        backend:
          serviceName: argocd-server
          servicePort: 80
---
EOF

 
