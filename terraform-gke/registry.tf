## CREATE DOCKER REGISTRY
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.repository_id
  format        = var.artifact_registry_repository_format
}

resource "google_artifact_registry_repository_iam_member" "member" {
  location    = module.gke_private-cluster.location
  project     = "${var.project_id}"
  repository  = "${var.repository_id}"
  role        = "${var.artifact_registry_repository_role_iam_member}"
  member      = "${var.artifact_registry_repository_iam_member}"
}

resource "google_project_iam_member" "project" {
  project     = "${var.project_id}"
  role        = "${var.artifact_registry_repository_role_iam_member}"
  member      = output.service_account_member
}