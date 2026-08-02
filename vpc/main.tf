module "network" {
  source = "../modules/network"

  project_id       = var.project_id
  region           = var.region
  network_name     = var.network_name
  routing_mode     = var.routing_mode
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
  ingress_rules    = var.ingress_rules
  egress_rules     = var.egress_rules

  enable_nat  = var.enable_nat
  router_name = var.router_name
  nat_name    = var.nat_name

  # NAT the private subnet (all its IP ranges, incl. pod/service secondary
  # ranges) so private GKE nodes and pods get outbound internet access.
  nat_target_subnet_names = [var.private_subnet_name]
}
