# Studies Plan w/ Mentor 2025/2026

This project is used as an intent to refresh my knoledge in Data Engineering. \
Course: https://github.com/DataTalksClub/data-engineering-zoomcamp

## Delivered repos/classes:
- [Classes 1.2](de_1.2);
  - [url2pg](https://github.com/bouli/url2pg): This repository ingests data from a CSV/Parquet url into a Postgres table;

#### Many thanks to [@cassiobolba](https://github.com/cassiobolba) who is helping me in this journey.

__

# WIP: Class 1.3 - Terraform!

## First approach with Terraform

After creating the GCP credential and set the
Here we are just saying we will you the GCP provider:

> [main.tf](main.tf)
```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.8.0"
    }
  }
}

provider "google" {
  project = "whalechant-460621"
  region  = "europe-west3"
  zone    = "europe-west3-a"
}
```

And now we add a simple bucket:
> [main.tf](main.tf)
```terraform
# (...)

resource "google_storage_bucket" "demo-bucket" {
  name          = "whalechant-460621-terraform-bucket"
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

```
