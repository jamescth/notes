#!/bin/bash

KUBERNETES_HOSTS=(10.0.1.21 10.0.1.22 10.0.1.23)

for host in ${KUBERNETES_HOSTS[*]}; do
  ssh james@${host} "sudo systemctl stop kube-proxy"
  ssh james@${host} "sudo systemctl stop kubelet"
  ssh james@${host} "sudo systemctl disable kube-proxy"
  ssh james@${host} "sudo systemctl disable kubelet"
  ssh james@${host} "sudo systemctl daemon-reload"
done
