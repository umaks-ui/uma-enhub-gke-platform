# -----------------------------------------------------------------------------
# Pull outputs from the vpc/ and iam/ root modules' remote state, so this
# root module never has to duplicate their resources or hardcode self_links.
# -----------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = var.vpc_state_bucket
    prefix = var.vpc_state_prefix
  }
}

data "terraform_remote_state" "iam" {
  backend = "gcs"
  config = {
    bucket = var.iam_state_bucket
    prefix = var.iam_state_prefix
  }
}

locals {
  network_self_link    = data.terraform_remote_state.vpc.outputs.network_self_link
  gke_subnet_self_link = data.terraform_remote_state.vpc.outputs.subnets_self_links[var.gke_subnet_name]
  gke_sa_email         = data.terraform_remote_state.iam.outputs.service_account_email
}

module "gke" {
  source = "../modules/gke"

  project_id           = var.project_id
  cluster_name         = var.cluster_name
  region               = var.region
  network_self_link    = local.network_self_link
  subnetwork_self_link = local.gke_subnet_self_link
  pods_range_name      = var.gke_pods_range_name
  services_range_name  = var.gke_services_range_name

  enable_private_nodes   = var.enable_private_nodes
  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  master_authorized_networks = var.master_authorized_networks
  maintenance_policy         = var.maintenance_policy
  release_channel            = var.release_channel

  workload_pool               = "${var.project_id}.svc.id.goog"
  node_service_account_email  = local.gke_sa_email

  enable_secret_manager      = var.enable_secret_manager
  enable_binary_authorization = var.enable_binary_authorization
  enable_fleet                = var.enable_fleet
  enable_backup                = var.enable_backup
  backup_cron_schedule        = var.backup_cron_schedule
  backup_delete_lock_days     = var.backup_delete_lock_days
  backup_retain_days          = var.backup_retain_days

  deletion_protection = var.deletion_protection
  resource_labels     = var.resource_labels
}

# -----------------------------------------------------------------------------
# Binary Authorization: the cluster-level enable_binary_authorization flag
# above only switches evaluation_mode to PROJECT_SINGLETON_POLICY_ENFORCE -
# what actually happens on admission is controlled by this project-wide
# policy resource.
#
# TODO before this does anything meaningful: no attestors are configured in
# this scaffold (none existed in the source spec), so evaluation_mode below
# defaults to ALWAYS_ALLOW - i.e. the policy exists and is wired up, but
# nothing is actually blocked or dry-run-logged yet. Once you create
# attestors (google_binary_authorization_attestor), set
# evaluation_mode = "REQUIRE_ATTESTATION" and populate
# require_attestations_by, and set binary_authorization_enforcement_mode to
# "DRYRUN_AUDIT_LOG_ONLY" (audit only) or "ENFORCED_BLOCK_AND_AUDIT_LOG"
# (enforce) as decided.
# -----------------------------------------------------------------------------
resource "google_binary_authorization_policy" "policy" {
  count   = var.enable_binary_authorization ? 1 : 0
  project = var.project_id

  default_admission_rule {
    evaluation_mode  = "ALWAYS_ALLOW"
    enforcement_mode = var.binary_authorization_enforcement_mode
  }

  global_policy_evaluation_mode = "ENABLE"
}
