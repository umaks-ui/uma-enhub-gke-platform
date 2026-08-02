variable "project_id" {
  description = "Project ID where the GKE Autopilot cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
}

variable "region" {
  description = "Region for the regional Autopilot cluster"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC the cluster attaches to (from the network module)"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of the private subnet the cluster's nodes/control plane attach to"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range used for Pod IPs (must exist on the subnet)"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range used for Service IPs (must exist on the subnet)"
  type        = string
}

variable "enable_private_nodes" {
  description = "Whether cluster nodes get only private, internal IP addresses"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "A /28 CIDR block for the control plane's private peering range. Must not overlap the VPC's subnets, pod range, or services range."
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the cluster's control plane (e.g. the bastion host/subnet). This is what enforces 'access not outside the bastion'."
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
  description = "GKE release channel: RAPID, REGULAR, or STABLE"
  type        = string
  default     = "STABLE"
}

variable "node_service_account_email" {
  description = "Email of the service account Autopilot workloads should run as (from the iam module/root)"
  type        = string
}

variable "workload_pool" {
  description = "Workload Identity pool, normally '<project_id>.svc.id.goog'"
  type        = string
}

variable "enable_secret_manager" {
  description = "Enable the GKE Secret Manager add-on (mount Secret Manager secrets as native Kubernetes Secrets/volumes)"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization on the cluster (evaluation_mode). Actual enforcement behavior (dry-run vs enforce) is set project-wide by the google_binary_authorization_policy resource in the gke/ root module."
  type        = bool
  default     = true
}

variable "enable_fleet" {
  description = "Whether to register this cluster into the project's Fleet (required for Anthos Service Mesh / Config Management)"
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
  description = "How many days to retain each backup before automatic deletion"
  type        = number
  default     = 30
}

variable "deletion_protection" {
  description = "Whether to block terraform destroy from deleting the cluster"
  type        = bool
  default     = true
}

variable "resource_labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}
