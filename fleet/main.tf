# -----------------------------------------------------------------------------
# Reads the gke/ root module's state to get the cluster's fleet membership,
# then enables + binds Service Mesh (ASM) and Config Management to it.
# Kept as its own root module (own state) so mesh/config-sync settings can
# be iterated on without ever touching the cluster or network.
# -----------------------------------------------------------------------------
data "terraform_remote_state" "gke" {
  backend = "gcs"
  config = {
    bucket = var.gke_state_bucket
    prefix = var.gke_state_prefix
  }
}

module "fleet" {
  source = "../modules/fleet"

  project_id    = var.project_id
  membership_id = var.membership_id != "" ? var.membership_id : data.terraform_remote_state.gke.outputs.cluster_name

  enable_service_mesh   = var.enable_service_mesh
  mesh_management_mode  = var.mesh_management_mode

  enable_config_management  = var.enable_config_management
  config_management_version = var.config_management_version
  config_sync_repo           = var.config_sync_repo
  config_sync_branch         = var.config_sync_branch
  config_sync_policy_dir     = var.config_sync_policy_dir
  config_sync_secret_type    = var.config_sync_secret_type
}
