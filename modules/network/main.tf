# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 9.0"

  project_id              = var.project_id
  network_name            = var.network_name
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
}

# -----------------------------------------------------------------------------
# Subnets (+ secondary ranges for GKE pods/services on the private subnet)
# -----------------------------------------------------------------------------
module "subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets = [
    for s in var.subnets : {
      subnet_name           = s.subnet_name
      subnet_ip              = s.subnet_ip
      subnet_region          = s.subnet_region
      subnet_private_access  = s.subnet_private_access
      subnet_flow_logs       = s.subnet_flow_logs
      description             = s.description
    }
  ]

  secondary_ranges = var.secondary_ranges

  depends_on = [module.vpc]
}

# -----------------------------------------------------------------------------
# Firewall rules
# -----------------------------------------------------------------------------
module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  depends_on = [module.vpc]
}

# -----------------------------------------------------------------------------
# Cloud Router + Cloud NAT
# Required because GKE nodes sit on the private subnet with no external IPs
# ("private nodes" per the spec) - NAT gives them outbound internet access
# for pulling images, hitting APIs, etc, without exposing them publicly.
# -----------------------------------------------------------------------------
resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = var.router_name
  project = var.project_id
  region  = var.region
  network = module.vpc.network_self_link
}

locals {
  # Subnets (from the subnets module we just created) that Cloud NAT should
  # cover, resolved by name so the root module only has to say *which*
  # subnets need NAT, not manage self_links itself.
  nat_target_subnets = {
    for name, subnet in module.subnets.subnets :
    subnet.name => subnet.self_link
    if contains(var.nat_target_subnet_names, subnet.name)
  }
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  name                               = var.nat_name
  project                            = var.project_id
  router                             = google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = local.nat_target_subnets
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [module.subnets]
}
