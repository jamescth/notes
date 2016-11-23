#!/bin/bash

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)
for host in ${KUBERNETES_HOSTS[*]}; do
  ssh james@${host} "sudo systemctl stop kube-scheduler"
  ssh james@${host} "sudo systemctl stop kube-controller-manager"
  ssh james@${host} "sudo systemctl stop kube-apiserver"
  ssh james@${host} "sudo systemctl disable kube-scheduler"
  ssh james@${host} "sudo systemctl disable kube-controller-manager"
  ssh james@${host} "sudo systemctl disable kube-apiserver"
  ssh james@${host} "sudo systemctl daemon-reload"
done
