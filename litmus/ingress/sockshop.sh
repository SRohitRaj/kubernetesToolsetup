#!/bin/sh
# export SOCKSHOP_HOST_PATH=sockshop.devopslab.tk

cat <<EOF | kubectl apply -f -
---
# prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  # different name
  name: letsencrypt-prod
  namespace: sock-shop
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
  name: sockshop-prod-cert
  namespace: sock-shop
spec:
  # dedicate secret for the TLS cert
  secretName: sockshop-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $SOCKSHOP_HOST_PATH
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-sockshop
  namespace: sock-shop
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
    - $SOCKSHOP_HOST_PATH
    # reference secret for production TLS certificate
    secretName: sockshop-production-certificate
  rules:
    - host: $SOCKSHOP_HOST_PATH
      http:
        paths:
          # - path: /sockshop(/|$)(.*)
          - path: /
            backend:
              serviceName: front-end
              servicePort: 80
---
EOF

kubectl patch svc front-end -n sock-shop -p '{"spec":{"type":"NodePort"}}'