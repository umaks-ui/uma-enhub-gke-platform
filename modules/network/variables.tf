variable "project_id" {
  description = "Project ID where the VPC, subnets, and firewall rules will be created"
  type        = string
}

variable "region" {
  description = "Region for the Cloud Router / Cloud NAT"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC to create"
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode: GLOBAL or REGIONAL"
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "Whether the VPC auto-creates subnets (should stay false, subnets module manages them explicitly)"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets to create. See terraform-google-modules/network/google//modules/subnets for full schema."
  type = list(object({
    subnet_name           = string
    subnet_ip              = string
    subnet_region          = string
    subnet_private_access  = optional(string, "true")
    subnet_flow_logs       = optional(string, "false")
    description             = optional(string)
  }))
}

variable "secondary_ranges" {
  description = "Map keyed by subnet_name of secondary IP ranges (used for GKE pod/service ranges)"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

variable "ingress_rules" {
  description = "List of ingress firewall rules"
  type = list(object({
    name          = string
    description   = optional(string)
    priority      = optional(number)
    source_ranges = optional(list(string), [])
    source_tags   = optional(list(string))
    target_tags   = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress firewall rules"
  type = list(object({
    name               = string
    description        = optional(string)
    priority           = optional(number)
    destination_ranges = optional(list(string), [])
    target_tags        = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
  default = []
}

variable "enable_nat" {
  description = "Whether to create a Cloud Router + Cloud NAT (needed so private GKE nodes get outbound internet access)"
  type        = bool
  default     = true
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
  default     = "uma-enhub-router"
}

variable "nat_name" {
  description = "Name of the Cloud NAT gateway"
  type        = string
  default     = "uma-enhub-nat"
}

variable "nat_target_subnet_names" {
  description = "Names of subnets (from var.subnets) that Cloud NAT should cover, e.g. the private subnet so private GKE nodes get outbound internet access"
  type        = list(string)
  default     = []
}
