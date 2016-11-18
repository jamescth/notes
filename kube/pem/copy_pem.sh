#!/bin/bash

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)

for host in ${KUBERNETES_HOSTS[*]}; do
  # ssh-copy-id -f james@${host}
  scp ca.pem james@${host}:~/
  scp kubernetes-key.pem james@${host}:~/
  scp kubernetes.pem james@${host}:~/
done
