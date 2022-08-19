

provider "rancher2" {
  api_url = var.rancher-url
  token_key = var.rancher-token
  insecure = true
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "xenon-axe-359616"
  region  = "us-central1"
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "tembici-rancher-tf-state-stg"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 1.2"
    }
  }
}