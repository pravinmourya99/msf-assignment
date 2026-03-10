# -----------------------------------------------------------------------------
# Project & environment - change these to run in any AWS account/region
# -----------------------------------------------------------------------------
project     = "msf"
environment = "dev"
aws_region  = "ap-southeast-1"

# -----------------------------------------------------------------------------
# Compartments (aligned with architecture diagram)
# Use 3 AZs for production; 2 AZs for dev is acceptable.
# -----------------------------------------------------------------------------
compartments = {
  # Internet Compartment: public, firewall, interfacing subnets
  internet = {
    vpc_cidr                = "10.0.0.0/16"
    enable_internet_gateway = true
    enable_nat_gateway      = true
    single_nat_gateway      = true
    enable_security_groups  = true
    subnets = [
      { name = "public-1", cidr = "10.0.1.0/24", availability_zone = "ap-southeast-1a", type = "public" },
      { name = "public-2", cidr = "10.0.2.0/24", availability_zone = "ap-southeast-1b", type = "public" },
      { name = "firewall-1", cidr = "10.0.10.0/24", availability_zone = "ap-southeast-1a", type = "firewall" },
      { name = "firewall-2", cidr = "10.0.11.0/24", availability_zone = "ap-southeast-1b", type = "firewall" },
      { name = "interfacing-1", cidr = "10.0.20.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.0.21.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }

  # GEN Compartment: government access - public, interfacing
  gen = {
    vpc_cidr                = "10.1.0.0/16"
    enable_internet_gateway = true
    enable_nat_gateway      = true
    single_nat_gateway      = true
    enable_security_groups  = true
    subnets = [
      { name = "public-1", cidr = "10.1.1.0/24", availability_zone = "ap-southeast-1a", type = "public" },
      { name = "public-2", cidr = "10.1.2.0/24", availability_zone = "ap-southeast-1b", type = "public" },
      { name = "interfacing-1", cidr = "10.1.20.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.1.21.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }

  # Workload Compartment Module X: web, compute, data, interfacing
  workload-x = {
    vpc_cidr                = "10.2.0.0/16"
    enable_internet_gateway = false
    enable_nat_gateway      = false
    single_nat_gateway      = true
    enable_security_groups  = true
    subnets = [
      { name = "web-1", cidr = "10.2.1.0/24", availability_zone = "ap-southeast-1a", type = "web" },
      { name = "web-2", cidr = "10.2.2.0/24", availability_zone = "ap-southeast-1b", type = "web" },
      { name = "compute-1", cidr = "10.2.10.0/24", availability_zone = "ap-southeast-1a", type = "compute" },
      { name = "compute-2", cidr = "10.2.11.0/24", availability_zone = "ap-southeast-1b", type = "compute" },
      { name = "data-1", cidr = "10.2.20.0/24", availability_zone = "ap-southeast-1a", type = "data" },
      { name = "data-2", cidr = "10.2.21.0/24", availability_zone = "ap-southeast-1b", type = "data" },
      { name = "interfacing-1", cidr = "10.2.30.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.2.31.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }

  # Workload Compartment Module Y
  workload-y = {
    vpc_cidr                = "10.3.0.0/16"
    enable_internet_gateway = false
    enable_nat_gateway      = false
    single_nat_gateway      = true
    enable_security_groups  = true
    subnets = [
      { name = "compute-1", cidr = "10.3.10.0/24", availability_zone = "ap-southeast-1a", type = "compute" },
      { name = "compute-2", cidr = "10.3.11.0/24", availability_zone = "ap-southeast-1b", type = "compute" },
      { name = "interfacing-1", cidr = "10.3.20.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.3.21.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }

  # Workload Compartment Module Z
  workload-z = {
    vpc_cidr                = "10.4.0.0/16"
    enable_internet_gateway = false
    enable_nat_gateway      = false
    single_nat_gateway      = true
    enable_security_groups  = true
    subnets = [
      { name = "compute-1", cidr = "10.4.10.0/24", availability_zone = "ap-southeast-1a", type = "compute" },
      { name = "compute-2", cidr = "10.4.11.0/24", availability_zone = "ap-southeast-1b", type = "compute" },
      { name = "interfacing-1", cidr = "10.4.20.0/24", availability_zone = "ap-southeast-1a", type = "interfacing" },
      { name = "interfacing-2", cidr = "10.4.21.0/24", availability_zone = "ap-southeast-1b", type = "interfacing" },
    ]
  }
}

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------
transit_gateway_default_route_table_association = "disable"
transit_gateway_default_route_table_propagation = "disable"

# -----------------------------------------------------------------------------
# TGW routes: which CIDRs each compartment can reach via TGW
# All compartments need routes to every other compartment's VPC CIDR for inter-VPC traffic.
# -----------------------------------------------------------------------------
tgw_routes = {
  "internet"   = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16", "10.4.0.0/16"]
  "gen"        = ["10.0.0.0/16", "10.2.0.0/16", "10.3.0.0/16", "10.4.0.0/16"]
  "workload-x" = ["10.0.0.0/16", "10.1.0.0/16", "10.3.0.0/16", "10.4.0.0/16"]
  "workload-y" = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16", "10.4.0.0/16"]
  "workload-z" = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
}

# -----------------------------------------------------------------------------
# PrivateLink: Producer (Workload Z exposes API via NLB + Endpoint Service)
# -----------------------------------------------------------------------------
privatelink_producers = [
  {
    compartment        = "workload-z"
    subnet_type        = "compute"
    service_suffix     = "api"
    allowed_principals = ["*"]
  }
]

# -----------------------------------------------------------------------------
# PrivateLink: Consumer (Workload Y consumes Workload Z's API via producer_compartment)
# -----------------------------------------------------------------------------
privatelink_consumers = [
  {
    compartment         = "workload-y"
    producer_compartment = "workload-z"
    endpoint_suffix     = "api"
  }
]

# -----------------------------------------------------------------------------
# Optional: extra tags
# -----------------------------------------------------------------------------
extra_tags = {}
