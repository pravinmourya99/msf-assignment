# -----------------------------------------------------------------------------
# Project & environment
# -----------------------------------------------------------------------------
variable "project" {
  description = "Project name (e.g. msf)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region (e.g. ap-south-1, us-east-1)"
  type        = string
}

# -----------------------------------------------------------------------------
# Compartments (aligned with diagram: internet, gen, workload-x, workload-y, workload-z)
# -----------------------------------------------------------------------------
variable "compartments" {
  description = "Map of compartment name to VPC and subnet configuration"
  type = map(object({
    vpc_cidr                 = string
    enable_internet_gateway  = optional(bool, false)
    enable_nat_gateway       = optional(bool, false)
    single_nat_gateway       = optional(bool, true)
    enable_security_groups   = optional(bool, true)
    subnets = list(object({
      name              = string
      cidr              = string
      availability_zone = string
      type              = string # public, firewall, interfacing, web, compute, data
    }))
  }))
}

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------
variable "transit_gateway_default_route_table_association" {
  description = "TGW default route table association (enable/disable)"
  type        = string
  default     = "disable"
}

variable "transit_gateway_default_route_table_propagation" {
  description = "TGW default route table propagation (enable/disable)"
  type        = string
  default     = "disable"
}

# -----------------------------------------------------------------------------
# PrivateLink (optional)
# -----------------------------------------------------------------------------
variable "privatelink_consumers" {
  description = "List of consumer configs: set either service_name (external) or producer_compartment (internal producer)"
  type = list(object({
    compartment         = string
    service_name        = optional(string)       # For external AWS or 3rd-party services
    producer_compartment = optional(string)       # For internal: use this producer's service_name
    endpoint_suffix     = optional(string, "api")
  }))
  default = []
}

variable "privatelink_producers" {
  description = "List of producer configs: { compartment, subnet_type, service_suffix, allowed_principals }"
  type = list(object({
    compartment        = string
    subnet_type        = string   # e.g. compute or interfacing
    service_suffix     = optional(string, "api")
    allowed_principals = optional(list(string), ["*"])
  }))
  default = []
}

# -----------------------------------------------------------------------------
# TGW routing: which CIDRs to route via TGW from each compartment
# -----------------------------------------------------------------------------
variable "tgw_routes" {
  description = "Map of compartment name to list of CIDR blocks to route via TGW (e.g. other compartment VPC CIDRs)"
  type        = map(list(string))
  default     = {}
}

# -----------------------------------------------------------------------------
# Extra tags
# -----------------------------------------------------------------------------
variable "extra_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
