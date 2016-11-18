#!/bin/bash
wget https://github.com/coreos/etcd/releases/download/v3.0.10/etcd-v3.0.10-linux-amd64.tar.gz

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)

for host in ${KUBERNETES_HOSTS[*]}; do
  ssh -t james@${host} "sudo mkdir -p /etc/etcd/"
  ssh -t james@${host} "sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/"

  scp etcd-v3.0.10-linux-amd64.tar.gz james@${host}:~/
  ssh -t james@${host} "tar -xvf etcd-v3.0.10-linux-amd64.tar.gz"
  ssh -t james@${host} "sudo mv etcd-v3.0.10-linux-amd64/etcd* /usr/bin"

  ssh -t james@${host} "sudo mkdir -p /var/lib/etcd"
done
