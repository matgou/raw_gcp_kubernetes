# data.tf

# Find base image for OS
data "google_compute_image" "debian" {
  family  = "debian-${var.debian_version}"
  project = "debian-cloud"
}

data "google_compute_subnetwork" "control-plane" {
  name   = "subnet-control-plane"
  region = var.region
}