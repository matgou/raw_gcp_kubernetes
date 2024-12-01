# gcs.tf

module "cloud_storage" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 8.0"

  project_id = var.project

  prefix           = "${local.cluster_name}-buckets-${local.cluster_uuid}"
  names            = ["config"]
  randomize_suffix = true

  bucket_policy_only = {
    "config" = true
  }

  folders = {
    "config" = ["certs"]
  }
  set_storage_admin_roles = true
  bucket_storage_admins = {
    "config" = join(",", [local.iam_service_account.bt, local.iam_service_account.cp, local.iam_service_account.n])
  }

  set_viewer_roles = true
  bucket_viewers = {
    "config" = ""
  }
  force_destroy = {
    "config" = true
  }
}
