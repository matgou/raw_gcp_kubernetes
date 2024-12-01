# vm-control-plane.tf

module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id    = var.project
  prefix        = "a-${split("-", local.cluster_uuid)[4]}"
  names         = ["cp", "n", "bt"]
  generate_keys = false
  display_name  = "Controle Plane Service Accounts"
  description   = "Controle Plane Service Accounts"

  project_roles = []
}
