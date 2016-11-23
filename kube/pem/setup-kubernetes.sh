#!/bin/bash

# wget https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/token.csv
# wget https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/authorization-policy.jsonl

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)
for host in ${KUBERNETES_HOSTS[*]}; do
  scp token.csv authorization-policy.jsonl james@${host}:~/
  ssh james@${host} "sudo mv token.csv authorization-policy.jsonl /var/lib/kubernetes/"

  ssh james@${host} 'bash -s' < kube-internal.sh
  # ssh james@${host} "kubectl get componentstatuses"
done

# verify cluster health from the 1st node
ssh james@${KUBERNETES_HOSTS} "kubectl get componentstatuses"
