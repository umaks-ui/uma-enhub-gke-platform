# -----------------------------------------------------------------------------
# Fleet (GKE Hub) features - project-scoped, enabled once per project.
# A project only ever has ONE Fleet; there is nothing to "name" or create
# beyond enabling it (it's implicitly created the first time a membership or
# feature is registered), so this module only turns on the two requested
# features and binds them to the GKE cluster's membership.
# -----------------------------------------------------------------------------

# Anthos Service Mesh - the GCP-managed equivalent of "raw" Istio.
resource "google_gke_hub_feature" "servicemesh" {
  count    = var.enable_service_mesh ? 1 : 0
  name     = "servicemesh"
  project  = var.project_id
  location = "global"
}

resource "google_gke_hub_feature_membership" "servicemesh" {
  count      = var.enable_service_mesh ? 1 : 0
  project    = var.project_id
  location   = "global"
  feature    = google_gke_hub_feature.servicemesh[0].name
  membership = var.membership_id

  mesh {
    management = var.mesh_management_mode
  }
}

# Anthos Config Management - GitOps-style policy/config sync from a repo.
resource "google_gke_hub_feature" "configmanagement" {
  count    = var.enable_config_management ? 1 : 0
  name     = "configmanagement"
  project  = var.project_id
  location = "global"
}

resource "google_gke_hub_feature_membership" "configmanagement" {
  count      = var.enable_config_management ? 1 : 0
  project    = var.project_id
  location   = "global"
  feature    = google_gke_hub_feature.configmanagement[0].name
  membership = var.membership_id

  configmanagement {
    version = var.config_management_version

    config_sync {
      source_format = "unstructured"

      git {
        sync_repo   = var.config_sync_repo
        sync_branch = var.config_sync_branch
        policy_dir  = var.config_sync_policy_dir
        secret_type = var.config_sync_secret_type
      }
    }
  }

  depends_on = [google_gke_hub_feature_membership.servicemesh]
}
