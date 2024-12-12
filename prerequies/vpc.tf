module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.3"

  project_id   = var.project
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "proxy-only-subnet"
      subnet_ip     = "10.10.30.0/24"
      subnet_region = var.region
      purpose       = "REGIONAL_MANAGED_PROXY"
      role          = "ACTIVE"
    },
    {
      subnet_name           = "subnet-control-plane"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Subnet for Kube Control Plane Nodes"
    },
    {
      subnet_name           = "subnet-workers"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Subnet for Kube Worker Nodes"
    },
  ]

  secondary_ranges = {
    subnet-workers       = []
    subnet-control-plane = []
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}


module "firewall-submodule" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "~> 9.0"
  project_id              = var.project
  network                 = module.vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = module.vpc.subnets_ips

  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp",
      ports    = ["8080", "6443", "2379-2380", "10250", "10259", "10257", "10256", "30000-32767"]
    },
  ]
  custom_rules = {
    // Example of custom tcp/udp rule
    allow-ssh = {
      description          = "Allow ssh INGRESS to port 22"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"] # source or destination ranges (depends on `direction`)
      use_service_accounts = false         # if `true` targets/sources expect list of instances SA, if false - list of tags
      targets              = null          # target_service_accounts or target_tags depends on `use_service_accounts` value
      sources              = null          # source_service_accounts or source_tags depends on `use_service_accounts` value
      rules = [{
        protocol = "tcp"
        ports    = ["22"]
        },
      ]

      extra_attributes = {
        disabled  = false
        priority  = 95
        flow_logs = false
      }
    }

    // health-check
    allow-healthcheck = {
      description          = "Allow healthcheck"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["35.191.0.0/16", "130.211.0.0/22"] # source or destination ranges (depends on `direction`)
      use_service_accounts = false                               # if `true` targets/sources expect list of instances SA, if false - list of tags
      targets              = null                                # target_service_accounts or target_tags depends on `use_service_accounts` value
      sources              = null                                # source_service_accounts or source_tags depends on `use_service_accounts` value
      rules = [{
        protocol = "tcp"
        ports    = ["6443"]
        },
      ]

      extra_attributes = {
        disabled  = false
        priority  = 95
        flow_logs = false
      }
    }

  }
}
