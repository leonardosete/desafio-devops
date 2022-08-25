## CREATE DOCKER REGISTRY
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.repository_id
  format        = var.artifact_registry_repository_format
}

# resource "google_artifact_registry_repository_iam_member" "member" {
#   project = "google_artifact_registry_repository.repository.${var.project_id}"
#   location = google_artifact_registry_repository.repository.module.gke_private-cluster.location
#   repository = "google_artifact_registry_repository.repository.${var.repository_id}"
#   role = "roles/artifactregistry.reader"
#   member = "serviceAccount:tf-gke-tembici-sre-clu-fpm1@tembici-sre.iam.gserviceaccount.com"
# }

resource "google_artifact_registry_repository_iam_member" "member" {
  project = "${var.project_id}"
  location = module.gke_private-cluster.location
  repository = "${var.repository_id}"
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:tf-gke-tembici-sre-clu-fpm1@tembici-sre.iam.gserviceaccount.com"
}