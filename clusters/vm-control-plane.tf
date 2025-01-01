# vm-control-plane.tf

module "cp_boostrap_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  region       = var.region
  project_id   = var.project
  machine_type = "n2-highcpu-2"
  spot         = false
  source_image = data.google_compute_image.debian.self_link
  subnetwork   = data.google_compute_subnetwork.control-plane.self_link
  metadata = {
    shutdown-script = join("\n", ["#!/bin/bash", "/usr/local/bin/reset-control_plane.sh"])
  }
  subnetwork_project = var.project
  startup_script = join("\n", [
    local.init_script,
    "gsutil ls gs://${module.cloud_storage.names["config"]}/provisioned; if [ $? == '0' ]; then exit 0; fi",
    "sleep 30",
    "bash /usr/local/bin/init-control_plane.sh",
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
    "gsutil cp /etc/cluster_config_bucket gs://${module.cloud_storage.names["config"]}/",
    "gsutil cp /etc/cluster_uuid gs://${module.cloud_storage.names["config"]}/",
    "gsutil cp /etc/cluster_name gs://${module.cloud_storage.names["config"]}/",
    "kubeadm token create --print-join-command > node_join_command.sh",
    "gsutil cp node_join_command.sh gs://${module.cloud_storage.names["config"]}/node_join_command.sh",
    "echo $(kubeadm token create --print-join-command)' --control-plane' > cp_join_command.sh",
    "gsutil cp cp_join_command.sh gs://${module.cloud_storage.names["config"]}/cp_join_command.sh",
    "gsutil cp /dev/null gs://${module.cloud_storage.names["config"]}/provisioned",
    "KUBECONFIG=/etc/kubernetes/admin.conf kubectl create configmap -n kube-system cluster-config --from-literal=cluster_name=$( cat /etc/cluster_name ) --from-literal=cluster_uuid=$( cat /etc/cluster_uuid ) --from-literal=cluster_config_bucket=$( cat /etc/cluster_config_bucket )",
    local.wait_all_cp_nodes_are_ok,
    "/usr/local/bin/reset-control_plane.sh",
    "shutdown"
    # wait other nodes to join cluster

  ])
  service_account = {
    email = local.service_account.bt
  }
  tags       = ["${var.cluster_name}-controlplane"]
  depends_on = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
}

module "cp_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"

  region       = var.region
  project_id   = var.project
  machine_type = "n2-highcpu-2"
  spot         = true
  source_image = data.google_compute_image.debian.self_link
  subnetwork   = "subnet-control-plane"
  metadata = {
    shutdown-script = join("\n", ["#!/bin/bash", "/usr/local/bin/reset-control_plane.sh"])
  }
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
  tags       = ["${var.cluster_name}-controlplane"]
  depends_on = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
}

module "node_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 12.0"

  region             = var.region
  project_id         = var.project
  machine_type       = "n2-highcpu-2"
  spot               = true
  source_image       = data.google_compute_image.debian.self_link
  subnetwork         = "subnet-workers"
  subnetwork_project = var.project
  startup_script = join("\n", [
    local.init_script,
    local.wait_cluster_ready_script,
    local.init_node_script,
  ])
  service_account = {
    email = local.service_account.n
  }
  tags       = ["${var.cluster_name}-nodes"]
  depends_on = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
}

module "mig_bootrap" {
  source             = "terraform-google-modules/vm/google//modules/umig"
  version            = "~> 11.0"
  project_id         = var.project
  region             = var.region
  hostname           = "bt-${local.cluster_uuid}"
  instance_template  = module.cp_boostrap_template.self_link
  named_ports        = local.named_ports
  num_instances      = local.mig_bootrap_num_instances
  depends_on         = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
  network            = null
  subnetwork         = "subnet-control-plane"
  subnetwork_project = var.project
  zones              = ["europe-west9-a"]
}

module "mig_cp" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 11.0"
  project_id        = var.project
  region            = var.region
  hostname          = "cp-${local.cluster_uuid}"
  instance_template = module.cp_instance_template.self_link
  named_ports       = local.named_ports
  target_size       = local.mig_cp_num_instances
  health_check      = local.health_check
  depends_on        = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
}

module "mig_nodes" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 11.0"
  project_id        = var.project
  region            = var.region
  hostname          = "n-${local.cluster_uuid}"
  instance_template = module.node_instance_template.self_link
  named_ports       = local.named_ports
  target_size       = 1
  #health_check      = local.health_check
  depends_on = [module.cloud_storage, google_storage_bucket_iam_member.read_binary]
}
