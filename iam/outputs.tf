output "service_account_email" {
  description = "Email of the GKE node/workload service account, consumed by the gke/ root module via remote state"
  value       = module.iam.service_account_email
}

output "service_account_id" {
  description = "Fully qualified ID of the GKE service account"
  value       = module.iam.service_account_id
}
