project        = "sandbox-mgoulin"
region         = "europe-west9"
zone_primary   = "europe-west9-a"
zone_secondary = "europe-west9-b"
zone_tertiary  = "europe-west9-c"

# prerequis 
binary_bucket_name = "kube-buckets-ciqh-binary-554b"

# debian_name
debian_name    = "bookworm"
debian_version = "12"

# Cluster info
cluster_name = "kube"
cluster_uuid = "e4a591e1-ef4a-46cc-a85c-44a341b79e04"
network_name = "cka-mycluster-net"

# Control Plane
cp_num_instances = 3

kubelet_pkg_version = "1.31.4-1.1"
kubeadm_pkg_version = "1.31.4-1.1"
kubectl_pkg_version = "1.31.4-1.1"
kube_version        = "1.31.4"
