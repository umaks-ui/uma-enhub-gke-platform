variable "project_id" {
  description = "GCP project ID (Fleet host project)"
  type        = string
}

variable "membership_id" {
  description = "Fleet membership ID for the target cluster (defaults to the cluster name when the cluster registered itself via fleet_project)"
  type        = string
}

variable "enable_service_mesh" {
  description = "Enable the Anthos Service Mesh fleet feature (GCP-managed equivalent of Istio)"
  type        = bool
  default     = true
}

variable "mesh_management_mode" {
  description = "MANAGEMENT_AUTOMATIC (Google manages the mesh control plane) or MANAGEMENT_MANUAL"
  type        = string
  default     = "MANAGEMENT_AUTOMATIC"
}

variable "enable_config_management" {
  description = "Enable the Anthos Config Management fleet feature (GitOps config/policy sync)"
  type        = bool
  default     = true
}

variable "config_management_version" {
  description = "Config Management operator version. Leave null to let Google pick the recommended version."
  type        = string
  default     = null
}

variable "config_sync_repo" {
  description = "Git repository Config Sync pulls cluster/namespace config from"
  type        = string
  default     = "https://github.com/umaks-ui/uma-enhub-config-root"
}

variable "config_sync_branch" {
  description = "Branch of config_sync_repo to sync"
  type        = string
  default     = "main"
}

variable "config_sync_policy_dir" {
  description = "Path within config_sync_repo containing the config-root (see the acm/ folder in this repo for a starter layout)"
  type        = string
  default     = "config-root"
}

variable "config_sync_secret_type" {
  description = "Auth method Config Sync uses against the repo: none (public repo), ssh, cookiefile, token, gcenode, gcpserviceaccount"
  type        = string
  default     = "none"
}
