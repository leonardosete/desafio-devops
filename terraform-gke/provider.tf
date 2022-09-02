## DOC UTILIZADA ##
# https://learnk8s.io/terraform-gke
# https://registry.terraform.io/providers/hashicorp/google/latest/docs

provider "google" {
  project = var.project_id
  region  = var.region
}
provider "tls" {
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "new-sre-tembici-tfstate-1"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.2"
    }
  }
}