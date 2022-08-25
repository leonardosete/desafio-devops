output "cluster_name" {
  description = "Cluster name"
  value       = module.gke_private-cluster.name
}

output "release_channel" {
  description = "Release Channel"
  value       = module.gke_private-cluster.release_channel
}

output "service_account_member" {
  value = module.gke_private-cluster.google_project_iam_member.cluster_service_account-metric_writer[0].member
}
