variable "project_id" {
  description = "The project ID to host the cluster in"
  default = "tembici-sre"
}
variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "tembici-sre-cluster"
}
variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "prod"
}
variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}
variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "tembici-gke-network"
}
variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "tembici-gke-subnet"
}
variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}

variable "release_channel" {
  description = "The release channel type"
  default     = "REGULAR"
}

variable "repository_id" {
  description = "Artifact Registry Repo Name"
  default     = "sre-docker-registry"
}

variable "artifact_registry_repository_format" {
  description = "Artifact Registry Type"
  default     = "DOCKER"
}

variable "cluster_admin" {
  description = "Service Account to Manage Cluster"
  default     = "terraform-cluster-admin"
}
