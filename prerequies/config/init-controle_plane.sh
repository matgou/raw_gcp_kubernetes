#!/bin/sh
#
#
cat >kubeadm-config.yaml <<EOF
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta4
kubernetesVersion: v1.31.0
controlPlaneEndpoint: "kube-kubeapi.kube.private:6443" # change this (see below)
networking:
  podSubnet: "100.64.0.0/16"
  serviceSubnet: "100.65.0.0/16"
  dnsDomain: "cluster.local"
imageRepository: "europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-k8s-repo-proxy"
dns:
  imageRepository: "europe-west9-docker.pkg.dev/sandbox-mgoulin/kube-docker-k8s-repo-proxy/coredns"
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF
sudo kubeadm init --config kubeadm-config.yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

