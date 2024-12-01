
# Base linux config
# config
echo ${cluster_name} > /etc/cluster_name
echo ${cluster_uuid} > /etc/cluster_uuid
echo ${cluster_config_bucket} > /etc/cluster_config_bucket

swapoff -a # disable swap

# Custom kernel options
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay 
br_netfilter
EOF
sudo modprobe overlay 
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF
sudo sysctl --system

# Install package
rm /etc/apt/sources.list.d/debian.sources
apt-get update
sudo apt install apt-transport-artifact-registry
echo "deb ar+https://${region}-apt.pkg.dev/remote/${project}/${apt-repository} ${debian-name} main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/artifact-registry.list
echo "deb ar+https://europe-west9-apt.pkg.dev/projects/sandbox-mgoulin kube-apt-bookworm main" | sudo tee -a /etc/apt/sources.list.d/artifact-registry.list
apt-get update
#apt-get upgrade -y
apt-get install -y cron-apt apt-transport-https ca-certificates curl gpg containerd 
echo "upgrade -y -o APT::Get::Show-Upgraded=true" | sudo tee /etc/cron-apt/action.d/4-YesUpgrade

# Install binaries
gsutil ls gs://kube-buckets-xexs-binary-a563/bin/** | while read fic; do gsutil cp $fic /tmp/; cd /usr/local/bin/; tar xvf /tmp/$(basename $fic); done;
gsutil ls "gs://kube-buckets-xexs-binary-a563/config/**" | while read fic; do gsutil cp $fic $(echo $fic | sed "s@gs://kube-buckets-xexs-binary-a563/config@@"); done; 

# containerd config
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sed -i 's@sandbox_image = ".*pause\(.*\)"@sandbox_image = "europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-k8s-repo-proxy/pause\1"@' /etc/containerd/config.toml
#mkdir -p /etc/containerd/certs.d/europe-west9-docker.pkg.dev
#cat <<EOF | sudo tee /etc/containerd/certs.d/europe-west9-docker.pkg.dev/hosts.toml
#server = "https://europe-west9-docker.pkg.dev"
#
#[host."http://europe-west9-docker.pkg.dev"]
#  capabilities = ["pull", "resolve"]
#EOF
sudo systemctl restart containerd
sudo systemctl enable containerd

# install kubernetes
# see: https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
#curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet
