module "apt-k8s" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.2"

  project_id    = var.project
  location      = var.region
  format        = "APT"
  repository_id = "${var.cluster_name}-apt-${var.debian_name}"
  members = {
    "readers" = ["allUsers"]
  }
}

module "apt-debian" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.2"

  project_id    = var.project
  location      = var.region
  format        = "APT"
  mode          = "REMOTE_REPOSITORY"
  repository_id = "${var.cluster_name}-apt-proxy-repo-${var.debian_name}"
  remote_repository_config = {
    apt_repository = {
      public_repository = {
        repository_base = "DEBIAN"
        repository_path = "debian/dists/${var.debian_name}"
      }
    }
  }
}

module "docker-k8s" {
  for_each = {
    "k8s"  = "https://registry.k8s.io"
    "ghcr" = "https://ghcr.io"
    "quay" = "https://quay.io"
  }
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.2"

  project_id    = var.project
  location      = var.region
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  repository_id = "${var.cluster_name}-docker-${each.key}-repo-proxy"
  remote_repository_config = {
    docker_repository = {
      custom_repository = {
        uri = each.value
      }

    }
  }
  members = {
    "readers" = ["allUsers"]
  }
}
