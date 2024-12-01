
module "gce-ilb" {
  source  = "terraform-google-modules/lb-internal/google"
  version = "~> 5.0"

  project                 = var.project
  region                  = var.region
  name                    = "${var.cluster_name}-ilb"
  ports                   = [local.named_ports[0].port]
  source_tags             = ["${var.cluster_name}-controlplane", "${var.cluster_name}-nodes"]
  target_tags             = ["${var.cluster_name}-controlplane"]
  subnetwork              = "subnet-control-plane"
  network                 = var.network_name
  health_check            = local.health_check
  firewall_enable_logging = true
  backends = [
    {
      group       = module.mig_bootrap.instance_group
      description = ""
      failover    = false
    },
    #{
    #  group       = module.mig_cp.instance_group
    #  description = ""
    #  failover    = false
    #},
  ]
}

resource "google_dns_record_set" "lb" {
  name         = "${var.cluster_name}-kubeapi.${var.cluster_name}.private."
  type         = "A"
  managed_zone = "${var.cluster_name}-zone"
  rrdatas      = [module.gce-ilb.ip_address]

}
