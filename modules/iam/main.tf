# -----------------------------------------------------------------------------
# Service account used by GKE Autopilot workloads / Workload Identity
# (service_accounts_iam only manages bindings on EXISTING SAs, so the SA
#  itself is created here with the plain google_service_account resource)
# -----------------------------------------------------------------------------
resource "google_service_account" "gke_sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# -----------------------------------------------------------------------------
# Project-level roles the SA needs to operate (logging, monitoring, pulling
# images, and reading Secret Manager secrets since Secret Manager is enabled)
# -----------------------------------------------------------------------------
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# -----------------------------------------------------------------------------
# IAM policy bindings ON the service account itself
# (e.g. Workload Identity User grants for specific KSAs)
# -----------------------------------------------------------------------------
module "service_accounts_iam" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "~> 8.0"

  project          = var.project_id
  service_accounts = [google_service_account.gke_sa.email]
  mode             = var.mode
  bindings         = var.bindings

  depends_on = [google_service_account.gke_sa]
}
