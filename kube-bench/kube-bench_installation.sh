#!/bin/bash
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.4.0/kube-bench_0.4.0_linux_amd64.tar.gz -o kube-bench_0.4.0_linux_amd64.tar.gz
tar -xvf kube-bench_0.4.0_linux_amd64.tar.gz 
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml

kubectl apply -f ~/tools/kube-bench/kube-bench-job.yaml

#curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.5.0/kube-bench_0.5.0_linux_amd64.tar.gz -o kube-bench_0.5.0_linux_amd64.tar.gz
#tar -xvf kube-bench_0.5.0_linux_amd64.tar.gz
#./kube-bench --config-dir ./cfg --config ./cfg/eks-1.0/config.yaml
