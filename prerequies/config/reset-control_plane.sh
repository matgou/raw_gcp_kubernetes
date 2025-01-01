#!/bin/sh
init-cli.sh

case $( hostname -s | cut -f1 -d- ) in
  cp)
    gcloud compute instance-groups managed abandon-instances $( hostname -s | cut -f1 -d- )-$( cat /etc/cluster_uuid )-mig --instances $( hostname -s ) --region europe-west9 || true
    ;;
  bt)
    gcloud compute instance-groups unmanaged remove-instances $( hostname -s | cut -f1 -d- )-$( cat /etc/cluster_uuid )-instance-group-001 --instances $( hostname -s ) --zone europe-west9-a || true
    ;;
esac
kubectl drain $( hostname -s ) --ignore-daemonsets --force=true
kubeadm reset -f
kubectl delete node $( hostname -s )

#export POD_NAME=$( kubectl get pod -n kube-system --selector=component=etcd  -o jsonpath='{.items[?(@.spec.nodeName!="'$( hostname -s )'")].metadata.name}' | awk '{print $1}')
#export ETCD_ID=$( kubectl exec -it $POD_NAME -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key member list | grep $( hostname -s ) | awk -F, '{ print $1 }' )
#kubectl exec -it $POD_NAME -n kube-system -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key member remove $ETCD_ID
