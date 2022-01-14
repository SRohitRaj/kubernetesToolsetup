#!/bin/sh
set -x


create_ingress(){
# export ARGOCD_HOST=argocd.letsdevops.tk


cat <<EOF | kubectl apply -f -
---
# prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  # different name
  name: letsencrypt-prod
  namespace: argocd
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
  name: argocd-prod-cert
  namespace: argocd
spec:
  # dedicate secret for the TLS cert
  secretName: argocd-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $ARGOCD_HOST
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-argocd
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # reference production issuer
    cert-manager.io/issuer: "letsencrypt-prod"
    # nginx.ingress.kubernetes.io/rewrite-target: /\$2
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - $ARGOCD_HOST
    # reference secret for production TLS certificate
    secretName: argocd-production-certificate
  rules:
    - host: $ARGOCD_HOST
      http:
        paths:
          # - path: /argocd(/|$)(.*)
          - path: /
            backend:
              serviceName: argocd-server
              servicePort: 443
---
EOF

kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'
}


prerequisite_check(){
  readyReplicas=$(kubectl get deployment.apps/$1 -n $2 -o jsonpath='{.status.readyReplicas}')
        replicas=$(kubectl get deployment.apps/$1 -n $2 -o jsonpath='{.status.replicas}')
        if [ "$readyReplicas" -eq "$replicas" ]
   then
    echo 'all good'
    echo "Deployment.apps/$1 $readyReplicas/$replicas Ready"
   else
    echo "Make sure $1 is running"
    exit
   fi
}
prerequisite_check cert-manager cert-manager
prerequisite_check ingress-nginx-controller ingress-nginx

a=0

while [ $a -lt 600 ]
do
   echo $a
  # Default username/password credentials: admin/admin
  argocd_readyReplicas=$(kubectl get deployment.apps/argocd-server -n argocd -o jsonpath='{.status.readyReplicas}')
  argocd_replicas=$(kubectl get deployment.apps/argocd-server -n argocd -o jsonpath='{.status.replicas}')
  if [ "$argocd_readyReplicas" -eq "$argocd_replicas" ]
  then
    echo 'all good'
    sleep 5
    create_ingress
    break
  else
    sleep 1
          echo "deployment.apps/argocd-server "$argocd_readyReplicas"/"$argocd_replicas" ready"
    a=`expr $a + 1`
  fi
done

set +x
