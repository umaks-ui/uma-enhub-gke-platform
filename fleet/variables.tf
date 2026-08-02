variable "project_id" {
  description = "GCP project ID (Fleet host project)"
  type        = string
}

variable "region" {
  description = "Default region for the google provider"
  type        = string
}

variable "gke_state_bucket" {
  description = "GCS bucket holding the gke/ root module's state"
  type        = string
}

variable "gke_state_prefix" {
  description = "GCS prefix holding the gke/ root module's state"
  type        = string
}

variable "membership_id" {
  description = "Fleet membership ID to bind features to. Leave empty to use the gke/ root module's cluster_name output (the default membership ID GKE assigns on fleet registration)."
  type        = string
  default     = ""
}

variable "enable_service_mesh" {
  description = "Enable Anthos Service Mesh (managed) - GCP's equivalent to Istio"
  type        = bool
  default     = true
}

variable "mesh_management_mode" {
  description = "MANAGEMENT_AUTOMATIC (Google manages the mesh control plane) or MANAGEMENT_MANUAL"
  type        = string
  default     = "MANAGEMENT_AUTOMATIC"
}

variable "enable_config_management" {
  description = "Enable Anthos Config Management (GitOps config/policy sync)"
  type        = bool
  default     = true
}

variable "config_management_version" {
  description = "Config Management operator version, or null to let Google pick"
  type        = string
  default     = null
}

variable "config_sync_repo" {
  description = "Git repo Config Sync pulls cluster/namespace config from"
  type        = string
  default     = "https://github.com/umaks-ui/uma-enhub-config-root"
}

variable "config_sync_branch" {
  description = "Branch to sync"
  type        = string
  default     = "main"
}

variable "config_sync_policy_dir" {
  description = "Path within the repo containing the config-root (matches the acm/config-root/ folder in this repo)"
  type        = string
  default     = "config-root"
}

variable "config_sync_secret_type" {
  description = "Auth method against the repo: none, ssh, cookiefile, token, gcenode, gcpserviceaccount"
  type        = string
  default     = "none"
}
