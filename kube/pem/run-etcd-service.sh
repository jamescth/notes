#!/bin/bash

KUBERNETES_HOSTS=(10.0.1.11 10.0.1.12 10.0.1.13)

for host in ${KUBERNETES_HOSTS[*]}; do
  ssh james@${host} 'bash -s' < etcd-internal.sh
  ssh james@${host} "sudo systemctl status etcd --no-pager"
done

# verify cluster health from the 1st node
ssh james@${KUBERNETES_HOSTS} "etcdctl --ca-file=/etc/etcd/ca.pem cluster-health"
