module "int-tcp-proxy" {
  source     = "./modules/net-lb-proxy-int"
  name       = "${var.cluster_name}-ilb"
  project_id = var.project
  region     = var.region
  port       = 6443
  address    = "10.10.10.41"
  backend_service_config = {
    port_name = local.named_ports[0].name
    backends = [
      { group = module.mig_bootrap.umig_details[0].id },
      { group = module.mig_cp.instance_group }
    ]
  }
  vpc_config = {
    subnetwork = "subnet-control-plane"
    network    = var.network_name
  }
}

#module "gce-ilb" {
#  source  = "terraform-google-modules/lb-internal/google"
#  version = "~> 5.0"
#
#  project                 = var.project
#  region                  = var.region
#  name                    = "${var.cluster_name}-ilb"
#  ports                   = [local.named_ports[0].port]
#  source_tags             = ["${var.cluster_name}-controlplane", "${var.cluster_name}-nodes"]
#  target_tags             = ["${var.cluster_name}-controlplane"]
#  subnetwork              = "subnet-control-plane"
#  network                 = var.network_name
#  health_check            = local.health_check
#  firewall_enable_logging = true
#  backends = [
#    {
#      group       = module.mig_bootrap.instance_group
#      description = ""
#      failover    = false
#    },
#    {
#      group       = module.mig_cp.instance_group
#      description = ""
#      failover    = false
#    },
#  ]
#}

resource "google_dns_record_set" "lb" {
  name         = "kubeapi-${local.cluster_uuid}.${var.cluster_name}.private."
  type         = "A"
  managed_zone = "${var.cluster_name}-zone"
  rrdatas      = [module.int-tcp-proxy.forwarding_rule.ip_address]

}
