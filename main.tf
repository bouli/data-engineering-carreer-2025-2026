terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.8.0"
    }
  }
}

provider "google" {
  project = "my-project"
  region  = "europe-west3"
  zone    = "europe-west3-a"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "my-bucket"
  location      = "EU"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
