project_id = "uma-enhub"
region     = "us-central1"

network_name = "uma-enhub-vpc"
routing_mode = "REGIONAL" # per spec: "Dynamic routing mode: regional"

private_subnet_name = "uma-enhub-private-subnet"

subnets = [
  {
    subnet_name           = "uma-enhub-public-subnet"
    subnet_ip              = "10.60.0.0/22"
    subnet_region          = "us-central1"
    subnet_private_access  = "true"
    subnet_flow_logs       = "false"
    description             = "Public subnet - bastion / external LBs / NAT egress IP"
  },
  {
    subnet_name           = "uma-enhub-private-subnet"
    subnet_ip              = "10.60.4.0/22"
    subnet_region          = "us-central1"
    subnet_private_access  = "true"
    subnet_flow_logs       = "true"
    description             = "Private subnet - GKE Autopilot nodes"
  }
]

secondary_ranges = {
  "uma-enhub-private-subnet" = [
    {
      # WARNING: 10.60.8.0/28 is only 16 IPs TOTAL for pods across the whole
      # cluster - this is the value given in the original spec ("Will
      # discuss over a call"). This is almost certainly too small for any
      # real Autopilot workload; a /20 or larger is the usual minimum.
      # Confirm and widen this before applying to a real environment.
      range_name    = "uma-enhub-pods-prod"
      ip_cidr_range = "10.60.8.0/28"
    },
    {
      range_name    = "uma-enhub-services-prod"
      ip_cidr_range = "10.62.0.0/20"
    }
  ]
}

ingress_rules = [
  {
    name          = "allow-iap-ssh-prod"
    description   = "Allow SSH from Identity-Aware Proxy range (bastion access)"
    priority      = 1000
    source_ranges = ["35.235.240.0/20"]
    allow = [
      { protocol = "tcp", ports = ["22"] }
    ]
  },
  {
    name          = "allow-internal-prod"
    description   = "Allow all internal traffic within the VPC"
    priority      = 1000
    source_ranges = ["10.60.0.0/16"]
    allow = [
      { protocol = "tcp", ports = ["0-65535"] },
      { protocol = "udp", ports = ["0-65535"] },
      { protocol = "icmp" }
    ]
  }
]

egress_rules = [
  {
    name               = "allow-all-egress-prod"
    description        = "Allow all outbound traffic (private nodes egress via Cloud NAT)"
    priority           = 1000
    destination_ranges = ["0.0.0.0/0"]
    allow = [
      { protocol = "all" }
    ]
  }
]

enable_nat  = true
router_name = "uma-enhub-router"
nat_name    = "uma-enhub-nat"
