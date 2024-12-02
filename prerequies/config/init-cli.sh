mkdir -p $HOME/.kube
gsutil cp gs://$( cat /etc/cluster_config_bucket )/certs/admin.conf $HOME/.kube/config