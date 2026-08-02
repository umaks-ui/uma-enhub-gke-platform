variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default region for the google provider"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally-unique GCS bucket name to hold all Terraform state for this platform"
  type        = string
}

variable "state_bucket_location" {
  description = "Location for the state bucket. Multi-regions (US) or a single region (us-central1) both work; pick one and never change it after creation."
  type        = string
  default     = "US"
}
