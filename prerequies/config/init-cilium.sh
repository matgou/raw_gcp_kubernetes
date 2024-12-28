
cp /etc/hosts /etc/hosts.backup
sed -i "s/\(.*\)\(kubeapi-.*private\)/127.0.0.1 \2/" /etc/hosts
cilium install \
  --set image.repository=europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-quay-repo-proxy/cilium/cilium \
  --set operator.image.repository=europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-quay-repo-proxy/cilium/operator
mv /etc/hosts.backup /etc/hosts