data "google_compute_network" "vpc" {
  name = var.network_name
}

resource "google_dns_managed_zone" "clusters" {
  name     = "${var.cluster_name}-zone"
  dns_name = "${var.cluster_name}.private."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.vpc.id
    }
  }
}
