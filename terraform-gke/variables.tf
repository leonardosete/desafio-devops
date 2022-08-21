variable "project_id" {
  description = "The project ID to host the cluster in"
  default = "xenon-axe-359616"
}
variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "tembici-devops-sre"
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
  default     = "gke-network"
}
variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
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

## ARTIFACT REGISTRY REPOSITORY
variable "repository_id" {
  description = "Repository name"
  default     = "tembici-docker-registry"
}

variable "format" {
  description = "Type of registry: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, GO"
  default = "DOCKER"
}
