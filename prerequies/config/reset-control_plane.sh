#!/bin/sh
init-cli.sh

gcloud compute instance-groups managed abandon-instances cp-$( cat /etc/cluster_uuid )-mig --instances $( hostname -s ) --region europe-west9 &

kubectl drain $( hostname -s ) --ignore-daemonsets --force=true
kubectl delete node $( hostname -s )
kubeadm reset -f

export POD_NAME=$( kubectl get pod -n kube-system --selector=component=etcd  -o jsonpath='{.items[?(@.spec.nodeName!="'$( hostname -s )'")].metadata.name}' | awk '{print $1}')
export ETCD_ID=$( kubectl exec -it $POD_NAME -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key member list | grep $( hostname -s ) | awk -F, '{ print $1 }' )

kubectl exec -it $POD_NAME -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key member remove $ETCD_ID
