mkdir -p $HOME/.kube
gsutil cp gs://$( cat /etc/cluster_config_bucket )/certs/admin.conf $HOME/.kube/config

export PATH="/usr/local/bin/etcd-v3.5.17-linux-amd64/:$PATH"
gsutil cp gs://$( cat /etc/cluster_config_bucket )/certs/etcd-ca.crt ~/.etcd-ca.crt
sudo cp /etc/kubernetes/pki/etcd/peer.key ~/.etcd-peer.key
sudo cp /etc/kubernetes/pki/etcd/peer.crt ~/.etcd-peer.crt
sudo chown $(id -nu) ~/.etcd-peer.*
export ETCDCTL_CACERT=~/.etcd-ca.crt
export ETCDCTL_CERT=~/.etcd-peer.crt
export ETCDCTL_KEY=~/.etcd-peer.key
export ETCDCTL_ENDPOINTS='https://127.0.0.1:2379'