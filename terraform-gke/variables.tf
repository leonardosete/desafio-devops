variable "project_id" {
  description = "The project ID to host the cluster in"
  default = "leosete-devops-4"
}
variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "tembici-cluster"
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

variable "repository_id" {
  description = "Artifact Registry Repo Name"
  default     = "sre-docker-registry"
}

variable "artifact_registry_repository_format" {
  description = "Artifact Registry Type"
  default     = "DOCKER"
}

variable "release_channel" {
  description = "The release channel type"
  default     = "REGULAR"
}

variable "node_pools_name" {
  description = "Node pool name"
  default = "tembici-node-pool"
}


## Certificate Authority ##



variable "tls_cert_cn" {
  description = "tls_cert_request_example_subject_common_name"
  default = "leosete7.com"
}

variable "tls_cert_org" {
  description = "tls_cert_request_example_subject_organization"
  default = "Leonardo Sete DevOps"
}

variable "pvt_ca_ca_pool_default_name" {
  description = "google_privateca_ca_pool_default_name"
  default = "Leonardo Sete DevOps"
}

variable "pvt_ca_ca_pool_default_tier" {
  description = "google_privateca_ca_pool_default_tier"
  default = "ENTERPRISE" ## ENTERPRISE or DEVOPS
}

variable "pvt_ca_crt_auth_default_ca_id" {
  description = "google_privateca_certificate_authority_default_certificate_authority_id"
  default = "leosete7-com" ## ENTERPRISE or DEVOPS
}

variable "pvt_ca_crt_default_lifetime" {
  description = "google_privateca_certificate_default_lifetime"
  default = "2592000s" ## 1 month
}

variable "pvt_ca_crt_default_name" {
  description = "google_privateca_certificate_default_name"
  default = "leosete7-com" ## ENTERPRISE or DEVOPS
}