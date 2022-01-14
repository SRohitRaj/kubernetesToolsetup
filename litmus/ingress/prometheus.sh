#!/bin/sh
# export PROMETHEUS_HOST_PATH=prometheus.devopslab.tk


cat <<EOF | kubectl apply -f -
---
# prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  # different name
  name: letsencrypt-prod
  namespace: monitoring
spec:
  acme:
    # now pointing to Let's Encrypt production API
    server: https://acme-v02.api.letsencrypt.org/directory
    email: sat30ishere@email.com
    privateKeySecretRef:
      # storing key material for the ACME account in dedicated secret
      name: account-key-prod
    solvers:
    - http01:
       ingress:
         class: nginx
---         
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  # different name
  name: prometheus-prod-cert
  namespace: monitoring
spec:
  # dedicate secret for the TLS cert
  secretName: prometheus-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $PROMETHEUS_HOST_PATH
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-prometheus
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # reference production issuer
    cert-manager.io/issuer: "letsencrypt-prod"
    # nginx.ingress.kubernetes.io/rewrite-target: /\$2
spec:
  tls:
  - hosts:
    - $PROMETHEUS_HOST_PATH
    # reference secret for production TLS certificate
    secretName: prometheus-production-certificate
  rules:
    - host: $PROMETHEUS_HOST_PATH
      http:
        paths:
          # - path: /prometheus(/|$)(.*)
          - path: /
            backend:
              serviceName: prometheus-k8s
              servicePort: 9090
---
EOF

kubectl patch svc prometheus-k8s -n monitoring -p '{"spec":{"type":"NodePort"}}'