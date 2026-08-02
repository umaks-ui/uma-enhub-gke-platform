output "network_name" {
  description = "Name of the created VPC"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "Self link of the created VPC"
  value       = module.vpc.network_self_link
}

output "network_id" {
  description = "ID of the created VPC"
  value       = module.vpc.network_id
}

output "subnets" {
  description = "Map of created subnet resources (keyed by region/name)"
  value       = module.subnets.subnets
}

# Convenience output: subnet_name => self_link, so callers (gke/) can look up
# the private subnet's self_link without hardcoding it.
output "subnets_self_links" {
  description = "Map of subnet_name => self_link for easy lookup by callers"
  value = {
    for key, subnet in module.subnets.subnets :
    subnet.name => subnet.self_link
  }
}

output "subnets_ip_cidr_ranges" {
  description = "Map of subnet_name => primary IP CIDR range"
  value = {
    for key, subnet in module.subnets.subnets :
    subnet.name => subnet.ip_cidr_range
  }
}
