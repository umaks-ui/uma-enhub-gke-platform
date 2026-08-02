# -----------------------------------------------------------------------------
# GKE Autopilot cluster - REWRITTEN to use the native google_container_cluster
# resource directly instead of the community
# terraform-google-modules/kubernetes-engine//modules/gke-autopilot-cluster
# wrapper.
#
# WHY: that community submodule's variable surface has shifted across major
# versions (confirmed while debugging the original failure - fields like
# enable_binary_authorization/enable_secret_manager_addon aren't reliably
# the right names depending on which version you land on). The native
# resource below is what that module calls internally anyway; using it
# directly removes an entire layer of version-drift risk. Every field here
# is a real, stable field on google_container_cluster (google provider ~> 6.0).
# -----------------------------------------------------------------------------
resource "google_container_cluster" "autopilot" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region # regional cluster - required for Autopilot

  enable_autopilot     = true
  deletion_protection  = var.deletion_protection
  resource_labels      = var.resource_labels

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # --- Private nodes / private endpoint --------------------------------------
  # "Enable private nodes: yes" + "Override control plane default private
  # endpoint subnet: disable" -> nodes are private, control plane keeps GKE's
  # own default peered subnet (no private_endpoint_subnetwork override here),
  # and the public endpoint stays reachable ONLY from the bastion CIDR below.
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  maintenance_policy {
    dynamic "daily_maintenance_window" {
      for_each = try([var.maintenance_policy.daily_maintenance_window], [])
      content {
        start_time = daily_maintenance_window.value.start_time
      }
    }
    dynamic "recurring_window" {
      for_each = try([var.maintenance_policy.recurring_window], [])
      content {
        start_time = recurring_window.value.start_time
        end_time   = recurring_window.value.end_time
        recurrence = recurring_window.value.recurrence
      }
    }
  }

  workload_identity_config {
    workload_pool = var.workload_pool
  }

  # Default service account / OAuth scopes GKE uses for the node pools it
  # auto-provisions behind the scenes for Autopilot workloads.
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = var.node_service_account_email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  # "Secret manager: Enable" (per spec)
  secret_manager_config {
    enabled = var.enable_secret_manager
  }

  # Binary Authorization: evaluation_mode is the ONLY thing this resource
  # controls (DISABLED or PROJECT_SINGLETON_POLICY_ENFORCE). What actually
  # happens on admission (block vs audit-only) is controlled separately by
  # the project-wide google_binary_authorization_policy resource in the
  # gke/ ROOT module (gke/main.tf), not here.
  binary_authorization {
    evaluation_mode = var.enable_binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  # Fleet registration - registers this cluster into the project's (single,
  # auto-created) Fleet. Fleet-level features (Service Mesh, Config
  # Management) are enabled and bound to this membership separately from the
  # fleet/ root module, once this cluster exists and this membership output
  # is available via remote state.
  dynamic "fleet" {
    for_each = var.enable_fleet ? [1] : []
    content {
      project = var.project_id
    }
  }
}

# -----------------------------------------------------------------------------
# Backup for GKE
# Separate resource - not part of google_container_cluster. Requires the
# gkebackup.googleapis.com API to be enabled on the project.
# -----------------------------------------------------------------------------
resource "google_gke_backup_backup_plan" "this" {
  count = var.enable_backup ? 1 : 0

  name     = "${var.cluster_name}-backup-plan"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.autopilot.id

  backup_schedule {
    cron_schedule = var.backup_cron_schedule
  }

  retention_policy {
    backup_delete_lock_days = var.backup_delete_lock_days
    backup_retain_days      = var.backup_retain_days
  }

  backup_config {
    include_volume_data = true
    include_secrets     = true
    all_namespaces      = true
  }
}
