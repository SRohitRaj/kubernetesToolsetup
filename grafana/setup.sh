#!/bin/sh
set -x

# Setup the Monitoring Infrastructure
# Create monitoring namespace on the cluster
cat <<EOF | kubectl apply -f - 
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
EOF
create_ingress(){
# export GRAFANA_HOST_PATH=grafana.devopslab.tk


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
  name: grafana-prod-cert
  namespace: monitoring
spec:
  # dedicate secret for the TLS cert
  secretName: grafana-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $GRAFANA_HOST_PATH
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-grafana
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
    - $GRAFANA_HOST_PATH
    # reference secret for production TLS certificate
    secretName: grafana-production-certificate
  rules:
    - host: $GRAFANA_HOST_PATH
      http:
        paths:
          # - path: /grafana(/|$)(.*)
          - path: /
            backend:
              serviceName: grafana
              servicePort: 3000
---
EOF
kubectl patch svc grafana -n monitoring -p '{"spec":{"type":"NodePort"}}'
}
# Setup Grafana
# Apply the grafana manifests after deploying prometheus for all metrics.
kubectl -n monitoring apply -f grafana/

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
  grafana_readyReplicas=$(kubectl get deployment.apps/grafana -n monitoring -o jsonpath='{.status.readyReplicas}')
  grafana_replicas=$(kubectl get deployment.apps/grafana -n monitoring -o jsonpath='{.status.replicas}')
  if [ "$grafana_readyReplicas" -eq "$grafana_replicas" ]
  then
    echo 'all good'
    sleep 5
    create_ingress
    break
  else
    sleep 1
	  echo "deployment.apps/grafana "$grafana_readyReplicas"/"$grafana_replicas" Ready"
    a=`expr $a + 1`
  fi
done

set +x

