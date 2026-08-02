project_id = "uma-enhub"
region     = "us-central1"

service_account_id           = "uma-enhub-gke-sa"
service_account_display_name = "Uma-enhub GKE Autopilot Service Account - prod"

project_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
  "roles/stackdriver.resourceMetadata.writer",
  "roles/artifactregistry.reader",
  "roles/secretmanager.secretAccessor", # Secret manager: enable (per spec)
]

sa_bindings = {
  # Example: let a specific Kubernetes ServiceAccount impersonate this GSA
  # via Workload Identity. Replace with your real namespace/KSA name(s).
  "roles/iam.workloadIdentityUser" = [
    "serviceAccount:uma-enhub.svc.id.goog[default/app-ksa]"
  ]
}
