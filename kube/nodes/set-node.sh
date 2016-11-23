#!/bin/bash

wget https://get.docker.com/builds/Linux/x86_64/docker-1.12.1.tgz

wget https://storage.googleapis.com/kubernetes-release/network-plugins/cni-07a8a28637e97b22eb8dfe710eeae1344f69d16e.tar.gz
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kubectl
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kube-proxy
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/kubelet
chmod +x kubectl kube-proxy kubelet

KUBERNETES_HOSTS=(10.0.1.21 10.0.1.22 10.0.1.23)

for host in ${KUBERNETES_HOSTS[*]}; do
  # .pem
  scp ca.pem kubernetes-key.pem kubernetes.pem james@${host}:~/
  ssh james@${host} "sudo mkdir -p /var/lib/kubernetes"
  ssh -t james@${host} "sudo cp ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/"

  # docker
  scp docker-1.12.1.tgz james@${host}:~/
  ssh -t james@${host} "tar -xvf docker-1.12.1.tgz"
  ssh -t james@${host} "sudo cp docker/docker* /usr/bin/"

  # kubelet
  ssh james@${host} "sudo mkdir -p /opt/cni"
  scp cni-07a8a28637e97b22eb8dfe710eeae1344f69d16e.tar.gz james@${host}:~/
  ssh james@${host} "sudo tar -xvf cni-07a8a28637e97b22eb8dfe710eeae1344f69d16e.tar.gz -C /opt/cni"

  scp kubectl kube-proxy kubelet james@${host}:~/
  ssh -t james@${host} "sudo mv kubectl kube-proxy kubelet /usr/bin"
  ssh james@${host} "sudo mkdir -p /var/lib/kubelet"

  ssh james@${host} 'bash -s' < node-internal.sh

done
