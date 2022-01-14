#!/bin/bash
kubectl get ns | grep -i 'chaos-testing' &> /dev/null
if [ $? == 0 ]; then
   echo "Chaos Mesh already installed"
else
   echo "Chaos Mesh not installed already. Installing Chaos Mesh now!"
   curl -sSL https://mirrors.chaos-mesh.org/v1.1.1/install.sh | bash
   bash $HOME/tools/chaos-mesh/chaos-ingress-script.sh
   echo "Hello"
fi
