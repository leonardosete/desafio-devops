## CREATE DOCKER REGISTRY
resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = "sre-docker-registry"
  description   = "DOCKER repository"
  format        = "DOCKER"
}