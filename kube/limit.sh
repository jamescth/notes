kubectl label nodes jsky disk=ssd

kubectl get node jsky --show-labels

kubectl label nodes/jsky disk-

#************************************************************
kubectl create namespace skyriver
kubectl get namespace

kubectl create -f compute-resources.yaml --namespace=skyriver
kubectl get quota --namespace=skyriver
kubectl create -f limitBusy.yaml --namespace=skyriver
kubectl get pods
kubectl describe pod

kubectl delete pod/busybox-sleep --namespace=skyriver
kubectl delete quota compute-resources --namespace=skyriver
kubectl delete namespace skyriver

#************************************************************

kubectl create -f compute-resources.yaml
kubectl get quota compute-resources
kubectl describe quota compute-resources
kubectl create -f limitBusy.yaml
kubectl get pods
kubectl describe pod

kubectl delete pod/busybox-sleep 
kubectl delete quota compute-resources 
kubectl delete namespace skyriver

#************************************************************
kubectl describe node kube3
Capacity:
 alpha.kubernetes.io/nvidia-gpu:	0
 cpu:					1
 memory:				2048444Ki
 pods:					110
Allocatable:
 alpha.kubernetes.io/nvidia-gpu:	0
 cpu:					1
 memory:				2048444Ki
 pods:					110

#************************************************************
# http://stackoverflow.com/questions/33354241/update-nodes-pod-capacity
# https://github.com/kubernetes/kubernetes/blob/54706661ad72d62ea0b494112a74e0467093c9f4/cmd/kubelet/app/server.go#L317
sudo vim /lib/systemd/system

# kubelet
/usr/bin/kubelet --kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin --cluster-dns=100.64.0.10 --cluster-domain=cluster.local --v=4

curl http://localhost:10255/healthz
curl http://localhost:10255/pods
curl http://localhost:10255/spec/

/etc/systemd/system/kubelet.service.d/10-kubeadm.conf


kubectl taint node jsky dedicated=skyriver:NoSchedule

apiVersion: v1
kind: Pod
metadata:
  name: busybox-sleep
  annotations:
    scheduler.alpha.kubernetes.io/tolerations: '[{"key":"dedicated", "value":"skyriver"}]'

