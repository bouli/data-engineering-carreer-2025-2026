terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.8.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.region
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "my-bucket-name"
  location      = var.location
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

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "test_dataset"
  location   = var.location
}

resource "google_bigquery_table" "default" {
  dataset_id          = google_bigquery_dataset.demo_dataset.dataset_id
  table_id            = "permalink_table"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "permalink",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The Permalink"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "State where the head office is located"
  }
]
EOF

}
