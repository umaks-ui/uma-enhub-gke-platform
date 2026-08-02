output "servicemesh_feature_id" {
  description = "Resource ID of the servicemesh fleet feature"
  value       = module.fleet.servicemesh_feature_id
}

output "configmanagement_feature_id" {
  description = "Resource ID of the configmanagement fleet feature"
  value       = module.fleet.configmanagement_feature_id
}
