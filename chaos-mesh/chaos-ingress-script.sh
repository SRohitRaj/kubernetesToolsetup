#!/bin/sh
cat <<EOF | kubectl apply -f - 
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubecost-ingress
  namespace: chaos-testing
  annotations:
    ingress.kubernetes.io/proxy-body-size: 100M
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/app-root: "/"
spec:
  rules:
  - host: $CHAOS_MESH_PATH
    http:
      paths:
      - path: /
        backend:
          serviceName: chaos-dashboard
          servicePort: 2333
---
EOF

 
