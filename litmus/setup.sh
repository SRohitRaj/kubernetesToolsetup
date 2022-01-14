#!/bin/sh
set -x
# Setup the LitmusChaos Infrastructure
# Install the litmus chaos operator and CRDs
kubectl apply -f litmus-operator-v1.13.3.yaml

# Install the litmus-admin serviceaccount for centralized/admin-mode of chaos execution
kubectl apply -f litmus-admin-rbac.yaml

# Install the chaos experiments in admin(litmus) namespace
kubectl apply -f experiments.yaml -n litmus


# # Setup the Monitoring Infrastructure
# # Create monitoring namespace on the cluster
# cat <<EOF | kubectl apply -f - 
# ---
# apiVersion: v1
# kind: Namespace
# metadata:
#   name: monitoring
# ---
# EOF

# # Setup prometheus TSDB
# # Model-1 (optional): Service monitor and prometheus operator model.
# # Create the operator to instantiate all CRDs
# kubectl -n monitoring apply -f prometheus/prometheus-operator/

# # Deploy monitoring components
# kubectl -n monitoring apply -f metrics-exporters-with-service-monitors/node-exporter/
# kubectl -n monitoring apply -f metrics-exporters-with-service-monitors/kube-state-metrics/
# kubectl -n litmus apply -f metrics-exporters-with-service-monitors/litmus-metrics/chaos-exporter/


# # Deploy prometheus instance and all the service monitors for targets
# kubectl -n monitoring apply -f prometheus/prometheus-configuration/

# # Note: To change the service type to NodePort, perform a kubectl edit svc prometheus-k8s -n monitoring and replace type: LoadBalancer to type: NodePort

# # optional: Alert manager
# kubectl -n monitoring apply -f alert-manager-with-service-monitor/

# # # Model-2 (optional): Prometheus scrape config model.
# # # Deploy prometheus components
# # kubectl -n monitoring apply -f prometheus/prometheus-scrape-configuration/

# # # Deploy metrics exporters
# # kubectl -n monitoring apply -f metrics-exporters/node-exporter/
# # kubectl -n monitoring apply -f metrics-exporters/kube-state-metrics/
# # kubectl -n litmus apply -f metrics-exporters/litmus-metrics/chaos-exporter/

# # Setup Grafana
# # Apply the grafana manifests after deploying prometheus for all metrics.
# kubectl -n monitoring apply -f grafana/

# # Default username/password credentials: admin/admin



# Monitor Chaos on Sock-Shop.
# Setup Sock-Shop Microservices Application
# Apply the sock-shop microservices manifests
kubectl apply -f sock-shop/

# Setup the Monitoring Components
# create service monitors for all the application services if using prometheus operator with service monitors.

kubectl -n sock-shop apply -f sample-application-service-monitors/sock-shop/


# # Execute the Chaos Experiments
# # For the sake of illustration, let us execute node and pod level, CPU hog experiments on the catalogue microservice & Memory Hog experiments on the orders microservice in a staggered manner.
# kubectl apply -f chaos-experiments/catalogue/catalogue-pod-cpu-hog.yaml

# # Wait for ~60s
# sleep 100
# kubectl apply -f chaos-experiments/orders/orders-pod-memory-hog.yaml

# # Wait for ~60s
# sleep 100
# kubectl apply -f chaos-experiments/catalogue/catalogue-node-cpu-hog.yaml

# # Wait for ~60s
# sleep 100
# kubectl apply -f chaos-experiments/orders/orders-node-memory-hog.yaml

# # Verify execution of chaos experiments
# kubectl describe chaosengine catalogue-pod-cpu-hog -n litmus
# kubectl describe chaosengine orders-pod-memory-hog -n litmus
# kubectl describe chaosengine catalogue-node-cpu-hog -n litmus
# kubectl describe chaosengine orders-node-memory-hog -n litmus
create_ingress(){
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
  sockshop_readyReplicas=$(kubectl get deployment.apps/front-end -n sock-shop -o jsonpath='{.status.readyReplicas}')
  sockshop_replicas=$(kubectl get deployment.apps/front-end -n sock-shop -o jsonpath='{.status.replicas}')
  if [ "$sockshop_readyReplicas" -eq "$sockshop_replicas" ]
  then
    echo 'all good'
    sleep 5
    create_ingress
    break
  else
    sleep 1
	  echo "deployment.apps/front-end "$sockshop_readyReplicas"/"$sockshop_replicas" Ready"
    a=`expr $a + 1`
  fi
done
set +x

