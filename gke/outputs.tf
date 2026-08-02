output "cluster_name" {
  description = "GKE Autopilot cluster name"
  value       = module.gke.cluster_name
}

output "cluster_id" {
  description = "GKE Autopilot cluster ID"
  value       = module.gke.cluster_id
}

output "cluster_endpoint" {
  description = "GKE Autopilot cluster control plane endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)"
  value       = module.gke.location
}

output "fleet_membership" {
  description = "Fleet membership resource name, consumed by the fleet/ root module via remote state"
  value       = module.gke.fleet_membership
}

output "backup_plan_id" {
  description = "Backup for GKE backup plan ID"
  value       = module.gke.backup_plan_id
}
