variable "project" {
  type = string
}
variable "region" {
  type = string
}
variable "zone_primary" {
  type = string
}
variable "zone_secondary" {
  type = string
}
variable "zone_tertiary" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_uuid" {
  type = string
}
variable "network_name" {
  type = string
}
variable "debian_name" {
  type = string
}
variable "debian_version" {
  type = string
}
variable "cp_num_instances" {
  description = "Number of instances to create"
}
variable "binary_bucket_name" {
  description = "Name of bucket initiated by prerequis containing binary and script"
}

variable "network_tier" {
  description = "Network network_tier"
  default     = "PREMIUM"
}

variable "kubelet_pkg_version" {
  description = "Version of kubelet pkg in debian repo"
  type        = string
}

variable "kubeadm_pkg_version" {
  description = "Version of kubeadm pkg in debian repo"
  type        = string
}
variable "kubectl_pkg_version" {
  description = "Version of kubectl pkg in debian repo"
  type        = string
}
variable "kube_version" {
  description = "Version of kubernetes version"
  type        = string
}
