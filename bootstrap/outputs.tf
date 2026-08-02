output "state_bucket_name" {
  description = "Name of the GCS bucket to reference in every backend-prod.hcl file"
  value       = google_storage_bucket.tfstate.name
}
