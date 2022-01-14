#!/bin/bash
kubectl get ns | grep -i 'argocd' &> /dev/null
if [ $? == 0 ]; then
   echo "GitOps ArgoCD already installed"
   bash tools/gitops/argo-cli.sh
else
   echo "ArgoCD is not installed. Installing ArgoCD now!"
   #Install ArgoCD
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

   #Install ArgoCD CLI
   VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
   curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
   chmod +x /usr/local/bin/argocd
   
   #Install Argo CLI
   bash $HOME/tools/gitops/argo-cli.sh
   bash $HOME/tools/gitops/argocd_ingress.sh
fi
