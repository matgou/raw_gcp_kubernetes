# gcs.tf


resource "random_string" "prefix" {
  length  = 4
  upper   = false
  special = false
}

module "cloud_storage" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 8.0"

  project_id = var.project

  prefix           = "${var.cluster_name}-buckets-${random_string.prefix.result}"
  names            = ["binary"]
  randomize_suffix = true

  bucket_policy_only = {
    "binary" = true
  }

  folders = {
    "binary" = ["bin"]
  }
}

output "gcs" {
  value = module.cloud_storage.buckets[*].id
}
# https://github.com/containernetworking/plugins/releases/download/v1.6.0/cni-plugins-linux-amd64-v1.6.0.tgz

resource "google_storage_bucket_object" "binaries" {
  for_each = {
    "cilium"  = "cilium-linux-amd64.tar.gz"
    "nerdctl" = "nerdctl-2.0.0-linux-amd64.tar.gz"
    "etcdctl" = "etcd-v3.5.17-linux-amd64.tar.gz"
  }
  name   = "bin/${each.value}"
  source = "${path.module}/binaries/${each.value}"
  bucket = module.cloud_storage.buckets[0].id
}
resource "google_storage_bucket_object" "addon" {
  for_each = {
    "/etc/profile.d/kube.sh"                                       = "etc_profile.d_kube.sh"
    "/usr/local/bin/init-control_plane.sh"                        = "init-control_plane.sh"
    "/usr/local/bin/reset-control_plane.sh"  = "reset-control_plane.sh"
    "/usr/local/bin/init-cilium.sh"                                = "init-cilium.sh"
    "/usr/local/bin/init-cli.sh"                                   = "init-cli.sh"
    "/usr/local/bin/etcd-backup.yaml"                              = "etcd-backup.yaml"
    "/usr/local/bin/debian.yaml"                                   = "debian.yaml"
    "/usr/local/bin/gcs-fuse-csi-driver_create-cert.sh"            = "gcs-fuse-csi-driver_create-cert.sh"
    "/usr/local/bin/gcs-fuse-csi-validating_admission_policy.yaml" = "gcs-fuse-csi-validating_admission_policy.yaml"
    "/usr/local/bin/gcs-fuse-csi-driver-specs-generated.yaml"      = "gcs-fuse-csi-driver-specs-generated.yaml"
  }
  name           = "config${each.key}"
  source         = "${path.module}/config/${each.value}"
  detect_md5hash = true
  bucket         = module.cloud_storage.buckets[0].id
}
output "md5" {
  value = [for fic in google_storage_bucket_object.addon : fic.md5hash]
}

