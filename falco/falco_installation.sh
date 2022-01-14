#!/bin/bash
# Installing Falco as a Helm Chart
#Reference Doc: https://github.com/falcosecurity/charts/tree/master/falco
helm repo add falcosecurity https://falcosecurity.github.io/charts

helm repo update

helm upgrade  falco falcosecurity/falco --install 

