output "cluster_id" {
  description = "GKE cluster ID (fully qualified resource name, used by Backup for GKE)"
  value       = google_container_cluster.autopilot.id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.autopilot.name
}

output "endpoint" {
  description = "GKE control plane endpoint"
  value       = google_container_cluster.autopilot.endpoint
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)"
  value       = google_container_cluster.autopilot.location
}

output "ca_certificate" {
  description = "Base64-encoded cluster CA certificate, for configuring the kubernetes/helm providers"
  value       = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

# Fleet membership resource name for this cluster, if fleet registration was
# enabled. try() guards against the attribute not existing on older provider
# versions that predate the `fleet` block's `membership` computed attribute.
output "fleet_membership" {
  description = "Fleet membership resource name for this cluster, if registered"
  value       = try(google_container_cluster.autopilot.fleet[0].membership, null)
}

output "backup_plan_id" {
  description = "Backup for GKE backup plan ID, if backup was enabled"
  value       = var.enable_backup ? google_gke_backup_backup_plan.this[0].id : null
}
