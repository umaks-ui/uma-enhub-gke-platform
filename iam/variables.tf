variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default region for the google provider"
  type        = string
}

variable "service_account_id" {
  description = "Account ID for the GKE node/workload service account"
  type        = string
  default     = "uma-enhub-gke-sa"
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "Uma-enhub GKE Autopilot Service Account"
}

variable "project_roles" {
  description = "Project-level roles granted to the GKE service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
    "roles/secretmanager.secretAccessor",
  ]
}

variable "sa_bindings" {
  description = "Map of role => members to bind directly on the service account (e.g. Workload Identity User)"
  type        = map(list(string))
  default     = {}
}
