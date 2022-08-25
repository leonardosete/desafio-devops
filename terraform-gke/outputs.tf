output "cluster_name" {
  description = "Cluster name"
  value       = module.gke_private-cluster.name
}

output "release_channel" {
  description = "Release Channel"
  value       = module.gke_private-cluster.release_channel
}

# output "service_account" {
#   description = "The service account to default running nodes as if not overridden in `node_pools`."
#   value = module.gke_private-cluster.service_account
# }
