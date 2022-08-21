output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "release_channel" {
  description = "Release Channel"
  value       = module.gke_private-cluster.release_channel
}
