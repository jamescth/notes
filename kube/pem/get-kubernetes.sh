#!/bin/bash

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kube-apiserver
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kube-controller-manager
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kube-scheduler
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kubectl
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl

for host in ${KUBERNETES_HOSTS[*]}; do
  ssh james@${host} "sudo mkdir -p /var/lib/kubernetes"
  ssh -t james@${host} "sudo cp ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/"

  scp kube-apiserver kube-controller-manager kube-scheduler kubectl james@${host}:~/
  ssh james@${host} "sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/"
done

