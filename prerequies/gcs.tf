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
  bucket_viewers = {
    "binary" = "serviceAccount:kube-cp-nodes-account@${var.project}.iam.gserviceaccount.com"
  }
  set_viewer_roles = true
}

output "gcs" {
  value = module.cloud_storage.buckets[*].id
}
# https://github.com/containernetworking/plugins/releases/download/v1.6.0/cni-plugins-linux-amd64-v1.6.0.tgz

resource "google_storage_bucket_object" "binaries" {
  for_each = {
    "cilium"  = "cilium-linux-amd64.tar.gz"
    "nerdctl" = "nerdctl-2.0.0-linux-amd64.tar.gz"
  }
  name   = "bin/${each.value}"
  source = "${path.module}/binaries/${each.value}"
  bucket = module.cloud_storage.buckets[0].id
}
resource "google_storage_bucket_object" "addon" {
  for_each = {
    "/etc/profile.d/kube.sh"                = "etc_profile.d_kube.sh"
    "/usr/local/bin/init-controle_plane.sh" = "init-controle_plane.sh"
    "/usr/local/bin/init-cilium.sh"         = "init-cilium.sh"
  }
  name           = "config${each.key}"
  source         = "${path.module}/config/${each.value}"
  detect_md5hash = true
  bucket         = module.cloud_storage.buckets[0].id
}
output "md5" {
  value = [for fic in google_storage_bucket_object.addon : fic.md5hash]
}

