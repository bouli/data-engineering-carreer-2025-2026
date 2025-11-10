# Data Engineering Zoomcamp - 1.3

In this class we have a first approach with `terraform` and the usage with `GCP`.\
The best friend here is the [official documentation](https://registry.terraform.io/namespaces/hashicorp).

## First approach with Terraform

After creating the GCP credential and set the credentials locally,
we create our first terraform file specifying GCP as our provider.
In this case, I'm using `europe-west3` as zone, but you can use other:

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

Here, we can create as well datasets and tables in  bigquery, for example.
> [main.tf](main.tf)
```terraform
...

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "test_dataset"
  location   = "EU"
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
```

## Variables

To use variables is simple, in this case we are using a separated file called
`variables.tf`. The terraform find it by itself.

> [variables.tf](variables.tf)
```terraform
variable "location" {
  description = "Location default"
  default     = "EU"
}

variable "project" {
  description = "Project default id"
  default     = "my-project-id"
}

variable "region" {
  description = "Project region"
  default     = "europe-west3"
}

variable "zone" {
  description = "Project zone"
  default     = "europe-west3-a"
}

variable "bq_dataset_name" {
  description = "This is a dataset"
  default     = "my_dataset"
}
```

The usage in the main file is super simple, just use var.<the-variable>, like the
example bellow:
> [main.tf](main.tf)
```terraform
...

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "test_dataset"
  location   = var.location
}
...
```

## Conclusion
To be honest, understanding how `terraform` works is not a big deal since you
really understand the resource you are using at your cloud platform. The basic
usage is really ok.
