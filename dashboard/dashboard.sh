#!/bin/sh
set -x

echo "Creating Kubernetes Dashboard"
kubectl apply -f tools/dashboard/dashboard_recommended.yaml
kubectl apply -f tools/dashboard/admin_user.yaml
kubectl apply -f tools/dashboard/sample_user.yaml
create_ingress(){
# export DASHBOARD_HOST_PATH=dashboard.letsdevops.tk


cat <<EOF | kubectl apply -f -
---
# prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  # different name
  name: letsencrypt-prod
  namespace: kubernetes-dashboard
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
kind: ClusterIssuer
metadata:
  # different name
  name: dashboard-prod-cert
  namespace: kubernetes-dashboard
spec:
  # dedicate secret for the TLS cert
  secretName: dashboard-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $DASHBOARD_HOST_PATH
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-dashboard
  namespace: kubernetes-dashboard
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
    - $DASHBOARD_HOST_PATH
    # reference secret for production TLS certificate
    secretName: dashboard-production-certificate
  rules:
    - host: $DASHBOARD_HOST_PATH
      http:
        paths:
          # - path: /dashboard(/|$)(.*)
          - path: /
            backend:
              serviceName: kubernetes-dashboard
              servicePort: 443
---
EOF

kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'
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
  dashboard_readyReplicas=$(kubectl get deployment.apps/kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.status.readyReplicas}')
  dashboard_replicas=$(kubectl get deployment.apps/kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.status.replicas}')
  if [ "$dashboard_readyReplicas" -eq "$dashboard_replicas" ]
  then
    echo 'all good'
    sleep 5
    create_ingress
    break
  else
    sleep 1
          echo "deployment.apps/kubernetes-dashboard "$dashboard_readyReplicas"/"$dashboard_replicas" ready"
    a=`expr $a + 1`
  fi
done

set +x
