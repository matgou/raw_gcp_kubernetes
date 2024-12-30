# vm-control-plane.tf

module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id    = var.project
  prefix        = local.iam_sa_prefix
  names         = ["cp", "n", "bt"]
  generate_keys = false
  display_name  = "${var.cluster_name} Service Account for kubernetes"
  description   = "${var.cluster_name} Service Account for kubernetes"

  project_roles = ["${var.project}=>roles/compute.instanceAdmin"]
}

resource "google_artifact_registry_repository_iam_member" "read_ar" {
  for_each = tomap({
    for iam in local.registries_iam : "${iam.registry}.${iam.sa}" => iam
  })
  repository = each.value.registry
  role       = "roles/artifactregistry.reader"
  member     = each.value.sa
  depends_on = [module.service_accounts]
}


resource "google_storage_bucket_iam_member" "read_binary" {
  for_each   = local.iam_service_account
  bucket     = var.binary_bucket_name
  role       = "roles/storage.objectViewer"
  member     = each.value
  depends_on = [module.service_accounts]
}
