output "service_account_email" {
  description = "Email of the created GKE service account"
  value       = google_service_account.gke_sa.email
}

output "service_account_id" {
  description = "Fully qualified ID of the created GKE service account"
  value       = google_service_account.gke_sa.id
}

output "service_account_name" {
  description = "Fully qualified resource name of the created GKE service account"
  value       = google_service_account.gke_sa.name
}
