variable "project_id" {
  description = "Project ID where the service account and IAM bindings will be created"
  type        = string
}

variable "service_account_id" {
  description = "Account ID (the part before @) for the GKE node/workload service account"
  type        = string
  default     = "uma-enhub-gke-sa"
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "Uma-enhub GKE Autopilot Service Account"
}

variable "mode" {
  description = "IAM binding mode for service_accounts_iam submodule: 'additive' or 'authoritative'"
  type        = string
  default     = "additive"
}

variable "project_roles" {
  description = "List of project-level IAM roles to grant the created service account"
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

variable "bindings" {
  description = "Map of role => list of members to bind directly ON the service account resource (e.g. Workload Identity User) via service_accounts_iam submodule"
  type        = map(list(string))
  default     = {}
}
