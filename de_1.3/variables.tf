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
