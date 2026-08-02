output "network_name" {
  description = "Name of the created VPC"
  value       = module.network.network_name
}

output "network_self_link" {
  description = "Self link of the created VPC"
  value       = module.network.network_self_link
}

output "network_id" {
  description = "ID of the created VPC"
  value       = module.network.network_id
}

output "subnets_self_links" {
  description = "Map of subnet_name => self_link, consumed by the gke/ root module via remote state"
  value       = module.network.subnets_self_links
}

output "subnets_ip_cidr_ranges" {
  description = "Map of subnet_name => primary IP CIDR range"
  value       = module.network.subnets_ip_cidr_ranges
}
