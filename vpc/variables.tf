variable "project_id" {
  description = "GCP project ID to deploy into"
  type        = string
}

variable "region" {
  description = "Default region for the google provider and Cloud Router/NAT"
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

variable "private_subnet_name" {
  description = "Name of the private subnet (used to target it for Cloud NAT)"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create in the VPC"
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
  description = "Map keyed by subnet_name of secondary IP ranges, used for GKE pod/service ranges"
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
  description = "Whether to create Cloud Router + Cloud NAT for the private subnet's outbound internet access"
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
