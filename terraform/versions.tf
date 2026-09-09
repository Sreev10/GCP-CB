terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
  }
  backend "gcs" {
    bucket = "practice-50016"
    prefix = "terraform/state/gke"
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}