#!/bin/bash
set -x
export KUBECONFIG="$(pwd)/gateway-kubeconfig" 
gcloud container clusters get-credentials autopilot-cluster-1 --region us-central1 --project yash-innovation 
export INGRESS_EXT_IP=$(kubectl -n default get svc kibana -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
terraform init 
echo "Ingress IP : "$INGRESS_EXT_IP
TERRAFORM_PLAN_RECORD="records=[\"${INGRESS_EXT_IP}\"]"
TERRAFORM_PLAN_NAME="name=${RECORD_NAME}"
TERRAFORM_PLAN_TYPE="type=${RECORD_TYPE}"
terraform plan -var $TERRAFORM_PLAN_TYPE -var $TERRAFORM_PLAN_RECORD -var $TERRAFORM_PLAN_NAME
terraform apply -var $TERRAFORM_PLAN_TYPE -var $TERRAFORM_PLAN_RECORD -var $TERRAFORM_PLAN_NAME -auto-approve 
