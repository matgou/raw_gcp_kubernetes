locals {
  cluster_name = var.cluster_name
  cluster_uuid = var.cluster_uuid
  registries = [
    "kube-apt-bookworm",
    "kube-apt-proxy-repo-bookworm",
    "kube-docker-ghcr-repo-proxy",
    "kube-docker-k8s-repo-proxy",
    "kube-docker-quay-repo-proxy",
  ]
  registries_iam = flatten([for registry in local.registries : [for sa in local.iam_service_account : { sa = sa, registry = registry }]])
  service_account = {
    "cp" = module.service_accounts.emails_list[1]
    "n"  = module.service_accounts.emails_list[2]
    "bt" = module.service_accounts.emails_list[0]
  }
  iam_sa_prefix = "a-${split("-", local.cluster_uuid)[4]}"
  iam_service_account = {
    "cp" = "serviceAccount:${local.iam_sa_prefix}-cp@${var.project}.iam.gserviceaccount.com"
    "n"  = "serviceAccount:${local.iam_sa_prefix}-n@${var.project}.iam.gserviceaccount.com"
    "bt" = "serviceAccount:${local.iam_sa_prefix}-bt@${var.project}.iam.gserviceaccount.com"
  }
  named_ports = [{
    name = "https"
    port = 6443
  }]
  health_check = {
    type                = "https"
    check_interval_sec  = 1
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 6443
    port_name           = "health-check-port"
    request             = ""
    request_path        = "/readyz"
    host                = "1.2.3.4"
    enable_log          = true
    enable_logging      = true
    initial_delay_sec   = 300
  }

  init_script = templatefile("${path.module}/scripts/os-custom.sh", {
    region                = var.region
    project               = var.project
    cluster_name          = local.cluster_name
    cluster_uuid          = local.cluster_uuid
    cluster_config_bucket = module.cloud_storage.names["config"]

    apt-repository     = "kube-apt-proxy-repo-bookworm"
    apt-k8s-repository = "kube-apt-bookworm"
    debian-name        = var.debian_name
  })
  wait_cluster_ready_script = "x=1; until [ \"$x\" = \"0\" ]; do sleep 1; echo wait; gsutil ls gs://${module.cloud_storage.names["config"]}/provisioned; x=$?; done;"
  download_config_script = join("\n", [
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/ca.crt                /etc/kubernetes/pki/ca.crt             ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/ca.key                /etc/kubernetes/pki/ca.key             ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/sa.key                /etc/kubernetes/pki/sa.key             ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/sa.pub                /etc/kubernetes/pki/sa.pub             ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/front-proxy-ca.crt    /etc/kubernetes/pki/front-proxy-ca.crt ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/front-proxy-ca.key    /etc/kubernetes/pki/front-proxy-ca.key ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/etcd-ca.crt           /etc/kubernetes/pki/etcd/ca.crt        ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/etcd-ca.key           /etc/kubernetes/pki/etcd/ca.key        ",
    "gsutil cp gs://${module.cloud_storage.names["config"]}/certs/admin.conf            /etc/kubernetes/admin.conf             ",
  ])
  init_cp_script   = "gsutil cp gs://${module.cloud_storage.names["config"]}/cp_join_command.sh - | bash"
  init_node_script = "gsutil cp gs://${module.cloud_storage.names["config"]}/node_join_command.sh - | bash"
}

