# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the regional Autopilot cluster"
  type        = string
}

# -----------------------------------------------------------------------------
# Remote state pointers - where to read the vpc/ and iam/ root modules' state
# -----------------------------------------------------------------------------
variable "vpc_state_bucket" {
  description = "GCS bucket holding the vpc/ root module's state"
  type        = string
}

variable "vpc_state_prefix" {
  description = "GCS prefix holding the vpc/ root module's state"
  type        = string
}

variable "iam_state_bucket" {
  description = "GCS bucket holding the iam/ root module's state"
  type        = string
}

variable "iam_state_prefix" {
  description = "GCS prefix holding the iam/ root module's state"
  type        = string
}

# -----------------------------------------------------------------------------
# GKE
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
}

variable "gke_subnet_name" {
  description = "Which subnet (created by vpc/) the GKE cluster should attach to"
  type        = string
}

variable "gke_pods_range_name" {
  description = "Secondary range name (created by vpc/) to use for Pod IPs"
  type        = string
}

variable "gke_services_range_name" {
  description = "Secondary range name (created by vpc/) to use for Service IPs"
  type        = string
}

variable "enable_private_nodes" {
  description = "Whether cluster nodes get only private, internal IP addresses"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "A /28 CIDR for the control plane's private peering range - must not overlap the VPC subnets, pod range, or services range"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the cluster control plane - this is what restricts access to the bastion"
  type = list(object({
    display_name = string
    cidr_block   = string
  }))
}

variable "maintenance_policy" {
  description = "Cluster maintenance window configuration"
  type = object({
    daily_maintenance_window = optional(object({
      start_time = string
    }))
    recurring_window = optional(object({
      start_time = string
      end_time   = string
      recurrence = string
    }))
  })
  default = {
    daily_maintenance_window = {
      start_time = "03:00"
    }
  }
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "STABLE"
}

variable "enable_secret_manager" {
  description = "Enable the GKE Secret Manager add-on"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization evaluation on the cluster"
  type        = bool
  default     = true
}

variable "binary_authorization_enforcement_mode" {
  description = "DRYRUN_AUDIT_LOG_ONLY (audit only) or ENFORCED_BLOCK_AND_AUDIT_LOG (enforce) - only takes effect once attestors are configured, see the TODO in main.tf"
  type        = string
  default     = "DRYRUN_AUDIT_LOG_ONLY"
}

variable "enable_fleet" {
  description = "Whether to register this cluster into the project's Fleet (required for Service Mesh / Config Management)"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Whether to create a Backup for GKE backup plan for this cluster"
  type        = bool
  default     = true
}

variable "backup_cron_schedule" {
  description = "Cron schedule for automated GKE backups"
  type        = string
  default     = "0 3 * * *"
}

variable "backup_delete_lock_days" {
  description = "Minimum age (days) a backup must reach before it can be deleted"
  type        = number
  default     = 7
}

variable "backup_retain_days" {
  description = "How many days to retain each backup"
  type        = number
  default     = 30
}

variable "deletion_protection" {
  description = "Block terraform destroy from deleting the cluster"
  type        = bool
  default     = true
}

variable "resource_labels" {
  description = "Labels applied to the GKE cluster"
  type        = map(string)
  default     = {}
}
