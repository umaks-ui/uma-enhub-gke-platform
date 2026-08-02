project_id = "uma-enhub"
region     = "us-central1"

# Where to read the vpc/ and iam/ root modules' state from
vpc_state_bucket = "uma-enhub-state-file-holder"
vpc_state_prefix = "gke-platform/prod/vpc"

iam_state_bucket = "uma-enhub-state-file-holder"
iam_state_prefix = "gke-platform/prod/iam"

cluster_name = "uma-enhub-prod-gke"

gke_subnet_name         = "uma-enhub-private-subnet"
gke_pods_range_name     = "uma-enhub-pods-prod"
gke_services_range_name = "uma-enhub-services-prod"

# "Enable private nodes: yes" (per spec)
enable_private_nodes = true

# Control-plane private peering range. Must not overlap 10.60.0.0/22,
# 10.60.4.0/22, 10.60.8.0/28, or 10.62.0.0/20 - 172.16.0.0/28 is outside all
# of those, but double-check against any other ranges already in use in this
# project before applying.
master_ipv4_cidr_block = "172.16.0.0/28"

# TODO: replace with the real bastion host/subnet CIDR. Per spec: "Access
# using DNS / IPv4 - config not outside the bastion" - only this CIDR should
# ever be able to reach the control plane's public endpoint.
master_authorized_networks = [
  {
    display_name = "bastion-host"
    cidr_block   = "10.60.0.0/22" # <-- placeholder: narrow this to the actual bastion IP/CIDR
  }
]

# "Override control plane default private endpoint subnet: disable" - so no
# private_endpoint_subnetwork override is set anywhere in this config; GKE
# uses its own default peered subnet for the control plane.

maintenance_policy = {
  daily_maintenance_window = {
    start_time = "03:00" # UTC
  }
}

release_channel = "STABLE" # per spec

enable_secret_manager = true # "Secret manager: Enable" (per spec)

enable_binary_authorization           = true                    # no preference given -> enabling with a safe, inert default
binary_authorization_enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"  # see TODO in gke/main.tf re: attestors

enable_fleet = true # "Fleet registration: Enabled" (per spec, needed for Service Mesh)

enable_backup           = true # per your answer: "Enable"
backup_cron_schedule    = "0 3 * * *"
backup_delete_lock_days = 7
backup_retain_days      = 30

deletion_protection = true # recommended for a prod cluster; flip to false if you want easier teardown

resource_labels = {
  team    = "platform"
  owner   = "uma-enhub"
  env     = "prod"
  project = "uma-enhub"
}
