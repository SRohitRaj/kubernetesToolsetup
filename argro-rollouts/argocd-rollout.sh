#!/bin/bash
kubectl get ns | grep -i 'argocd-rollouts' &> /dev/null
if [ $? == 0 ]; then
   echo "ArgoCD Rollouts already installed"
else
   echo "Installing Rollouts now!"
   #Install argocd rollout
   kubectl apply -f tools/argro-rollouts/argocd-rollout-namespace.yaml
   kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
   curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
   chmod +x ./kubectl-argo-rollouts-linux-amd64
   sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
   kubectl argo rollouts version
fi
