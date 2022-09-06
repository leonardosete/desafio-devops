## DOC UTILIZADA ##
# https://learnk8s.io/terraform-gke
# https://registry.terraform.io/providers/hashicorp/google/latest/docs

provider "google" {
  project = var.project_id
  region  = var.region
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "fork-project-1"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}