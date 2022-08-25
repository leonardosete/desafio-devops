output "cluster_name" {
  description = "Cluster name"
  value       = module.gke_private-cluster.name
}

output "release_channel" {
  description = "Release Channel"
  value       = module.gke_private-cluster.release_channel
}

output "service_account" {
  description = "Release Channel"
  value       = module.gke_private-cluster.service_account
}

output "zones" {
  description = "Release Channel"
  value       = module.gke_private-cluster.zones
}

