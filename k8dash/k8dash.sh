#!/bin/sh

kubectl apply -f $HOME/tools/k8dash/k8dash.yaml 

# export K8DASH_HOST_PATH=k8dash.devopslab-result.tk
echo "Test"
echo $K8DASH_HOST_PATH
create_issuer(){
	cat <<EOF | kubectl apply -f - 
---
# prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  # different name
  name: letsencrypt-prod
  namespace: k8dash
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
  name: k8dash-prod-cert
  namespace: k8dash
spec:
  # dedicate secret for the TLS cert
  secretName: k8dash-production-certificate
  issuerRef:
    # referencing the production issuer
    name: letsencrypt-prod
  dnsNames:
  - $K8DASH_HOST_PATH
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-k8dash
  namespace: k8dash
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
    - $K8DASH_HOST_PATH
    # reference secret for production TLS certificate
    secretName: k8dash-production-certificate
  rules:
    - host: $K8DASH_HOST_PATH
      http:
        paths:
          # - path: /k8dash(/|$)(.*)
          - path: /
            backend:
              serviceName: k8dash
              servicePort: 80
--- 
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: null
  name: k8dash-sa
  namespace: k8dash
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: k8dash-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: k8dash-sa
  namespace: k8dash
---
EOF
}
a=0

while [ $a -lt 600 ]
do
   echo $a
	CM_RR=$(kubectl get deployment.apps/cert-manager -n cert-manager -o jsonpath='{.status.readyReplicas}')
	CM_R=$(kubectl get deployment.apps/cert-manager -n cert-manager -o jsonpath='{.status.replicas}')

	CM_RR_CI=$(kubectl get deployment.apps/cert-manager-cainjector -n cert-manager -o jsonpath='{.status.readyReplicas}')
	CM_R_CI=$(kubectl get deployment.apps/cert-manager-cainjector -n cert-manager -o jsonpath='{.status.replicas}')

	CM_RR_W=$(kubectl get deployment.apps/cert-manager-webhook -n cert-manager -o jsonpath='{.status.readyReplicas}')
	CM_R_W=$(kubectl get deployment.apps/cert-manager-webhook -n cert-manager -o jsonpath='{.status.replicas}')
	if [ "$CM_RR" -eq "$CM_R" -a "$CM_RR_CI" -eq "$CM_R_CI" -a "$CM_RR_W" -eq "$CM_R_W" ]
   then
      echo 'all good'
	  echo "CM_RR: "$CM_RR 
	  echo "CM_R: "$CM_R
	  echo "CM_RR_CI: "$CM_RR_CI 
	  echo "CM_R_CI: "$CM_R_CI
	  echo "CM_RR_W: "$CM_RR_W 
	  echo "CM_R_W: "$CM_R_W
	  create_issuer
	  break
   else
      sleep 1
      a=`expr $a + 1`
   fi
done

# # Create the service account in the current namespace (we assume default)
# kubectl create serviceaccount k8dash-sa

# # Give that service account root on the cluster
# kubectl create clusterrolebinding k8dash-sa --clusterrole=cluster-admin --serviceaccount=k8dash:k8dash-sa

# # Find the secret that was created to hold the token for the SA
# kubectl get secrets -n k8dash

# # Show the contents of the secret to extract the token
# kubectl describe secret -n k8dash k8dash-sa-token-<-----> 



# # delete setup 
# kubectl delete service/k8dash -n k8dash
# kubectl delete service/k8dash -n k8dash
# kubectl delete ns k8dash 
