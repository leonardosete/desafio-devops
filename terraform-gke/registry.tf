## CREATE DOCKER REGISTRY
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.repository_id
  format        = var.artifact_registry_repository_format
}
resource "google_project_iam_member" "cluster_service_account-artifact_reader" {
  project     = "${var.project_id}"
  role        = "${var.artifact_registry_repository_role_iam_member}"
  member      = module.gke_private-cluster.service_account
}