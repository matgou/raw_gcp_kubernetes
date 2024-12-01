# vm-control-plane.tf

module "cp_boostrap_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"

  region             = var.region
  project_id         = var.project
  machine_type       = "n2-standard-4"
  source_image       = data.google_compute_image.debian.self_link
  subnetwork         = "subnet-control-plane"
  subnetwork_project = var.project
  startup_script = join("\n", [
    local.init_script,
    "bash /usr/local/bin/init-controle_plane.sh",
    "bash /usr/local/bin/init-cilium.sh",
    "gsutil cp /etc/kubernetes/pki/ca.crt gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/ca.key gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/sa.key gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/sa.pub gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/front-proxy-ca.crt gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/front-proxy-ca.key gs://${module.cloud_storage.names["config"]}/certs/",
    "gsutil cp /etc/kubernetes/pki/etcd/ca.crt gs://${module.cloud_storage.names["config"]}/certs/etcd-ca.crt",
    "gsutil cp /etc/kubernetes/pki/etcd/ca.key gs://${module.cloud_storage.names["config"]}/certs/etcd-ca.key",
    "gsutil cp /etc/kubernetes/admin.conf gs://${module.cloud_storage.names["config"]}/certs/",
    "kubeadm token create --print-join-command > node_join_command.sh",
    "gsutil cp node_join_command.sh gs://${module.cloud_storage.names["config"]}/node_join_command.sh",
    "echo $(kubeadm token create --print-join-command)' --control-plane' > cp_join_command.sh",
    "gsutil cp cp_join_command.sh gs://${module.cloud_storage.names["config"]}/cp_join_command.sh",
    "gsutil cp /dev/null gs://${module.cloud_storage.names["config"]}/provisioned"
  ])
  service_account = {
    email = local.service_account.bt
  }
  tags = ["${var.cluster_name}-controlplane"]
}

module "cp_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"

  region             = var.region
  project_id         = var.project
  machine_type       = "n2-standard-4"
  source_image       = data.google_compute_image.debian.self_link
  subnetwork         = "subnet-control-plane"
  subnetwork_project = var.project
  startup_script = join("\n", [
    local.init_script,
    local.wait_cluster_ready_script,
    local.download_config_script,
    local.init_cp_script,
  ])
  service_account = {
    email = local.service_account.cp
  }
  tags = ["${var.cluster_name}-controlplane"]
}

module "node_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"

  region             = var.region
  project_id         = var.project
  machine_type       = "n2-standard-4"
  source_image       = data.google_compute_image.debian.self_link
  subnetwork         = "subnet-control-plane"
  subnetwork_project = var.project
  startup_script = join("\n", [
    local.init_script,
    local.wait_cluster_ready_script,
    local.init_node_script,
  ])
  service_account = {
    email = local.service_account.n
  }
  tags = ["${var.cluster_name}-nodes"]
}

module "mig_bootrap" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 11.0"
  project_id        = var.project
  region            = var.region
  hostname          = "bt-${local.cluster_uuid}"
  instance_template = module.cp_boostrap_template.self_link
  named_ports       = local.named_ports
  target_size       = 1
  health_check      = local.health_check
}

module "mig_cp" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 11.0"
  project_id        = var.project
  region            = var.region
  hostname          = "cp-${local.cluster_uuid}"
  instance_template = module.cp_instance_template.self_link
  named_ports       = local.named_ports
  target_size       = 3
  health_check      = local.health_check
}

module "mig_nodes" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 11.0"
  project_id        = var.project
  region            = var.region
  hostname          = "n-${local.cluster_uuid}"
  instance_template = module.node_instance_template.self_link
  named_ports       = local.named_ports
  target_size       = 3
  health_check      = local.health_check
}

#module "cp_bootstrap" {
#  source  = "terraform-google-modules/vm/google//modules/compute_instance"
#  version = "~> 12.0"
#
#  region              = var.region
#  zone                = var.zone_primary
#  subnetwork          = "subnet-control-plane"
#  subnetwork_project  = var.project
#  num_instances       = 2
#  hostname            = "${var.cluster_name}-boostrap"
#  instance_template   = module.cp_instance_template.self_link
#  deletion_protection = false
#}
