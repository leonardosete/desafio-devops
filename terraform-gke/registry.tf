## CREATE DOCKER REGISTRY
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.repository_id
  format        = var.artifact_registry_repository_format
}

resource "google_artifact_registry_repository_iam_member" "member" {
  project     = "google_artifact_registry_repository.repository.${var.project_id}"
  location    = "google_artifact_registry_repository.repository.${var.region}"
  repository  = "google_artifact_registry_repository.repository.${var.repository_id}"
  role        = var.artifact_registry_repository_role
  member      = "serviceAccount:${module.gke_private-cluster.service_account}"
}