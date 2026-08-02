project_id = "uma-enhub"
region     = "us-central1"

gke_state_bucket = "uma-enhub-state-file-holder"
gke_state_prefix = "gke-platform/prod/gke"

# Leave "" to use gke/'s cluster_name output as the membership ID (default
# GKE assigns this automatically when fleet_project is set on the cluster).
membership_id = ""

enable_service_mesh  = true              # "Managed service mesh: use this instead of Istio" (per spec)
mesh_management_mode = "MANAGEMENT_AUTOMATIC" # per spec: "ASM" / automatic mesh management

enable_config_management  = true # per your answer: enable both fleet features
config_management_version = null # let Google pick the recommended version

# TODO: point this at your real config-sync repo once you've pushed the
# acm/config-root/ folder from this bundle somewhere Config Sync can reach.
config_sync_repo       = "https://github.com/umaks-ui/uma-enhub-config-root"
config_sync_branch     = "main"
config_sync_policy_dir = "config-root"
config_sync_secret_type = "none"
