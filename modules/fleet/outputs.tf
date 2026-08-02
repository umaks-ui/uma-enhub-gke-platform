output "servicemesh_feature_id" {
  description = "Resource ID of the servicemesh fleet feature, if enabled"
  value       = var.enable_service_mesh ? google_gke_hub_feature.servicemesh[0].id : null
}

output "configmanagement_feature_id" {
  description = "Resource ID of the configmanagement fleet feature, if enabled"
  value       = var.enable_config_management ? google_gke_hub_feature.configmanagement[0].id : null
}
