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

# Setup prometheus TSDB
# Model-1 (optional): Service monitor and prometheus operator model.
# Create the operator to instantiate all CRDs
kubectl -n monitoring apply -f prometheus/prometheus-operator/

# Deploy monitoring components
kubectl -n monitoring apply -f metrics-exporters-with-service-monitors/node-exporter/
kubectl -n monitoring apply -f metrics-exporters-with-service-monitors/kube-state-metrics/
kubectl -n litmus apply -f metrics-exporters-with-service-monitors/litmus-metrics/chaos-exporter/


# Deploy prometheus instance and all the service monitors for targets
kubectl -n monitoring apply -f prometheus/prometheus-configuration/

# Note: To change the service type to NodePort, perform a kubectl edit svc prometheus-k8s -n monitoring and replace type: LoadBalancer to type: NodePort

# optional: Alert manager
kubectl -n monitoring apply -f alert-manager-with-service-monitor/

create_ingress(){
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
  prometheus_readyReplicas=$(kubectl get statefulset.apps/prometheus-k8s -n monitoring -o jsonpath='{.status.readyReplicas}')
  prometheus_replicas=$(kubectl get statefulset.apps/prometheus-k8s -n monitoring -o jsonpath='{.status.replicas}')
  if [ "$prometheus_readyReplicas" -eq "$prometheus_replicas" ]
  then
    echo 'all good'
    sleep 5
    create_ingress
    break
  else
    sleep 1
          echo "statefulset.apps/prometheus-k8s "$prometheus_readyReplicas"/"$prometheus_replicas" ready"
    a=`expr $a + 1`
  fi
done

set +x
