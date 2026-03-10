variable "name_prefix" {
  description = "Prefix for resource names (e.g. project-env)"
  type        = string
}

variable "compartment_name" {
  description = "Name of the compartment (e.g. internet, gen, workload-x)"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (interfacing subnets) for the attachment"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "dns_support" {
  description = "Enable DNS support for the attachment"
  type        = string
  default     = "enable"
}

variable "ipv6_support" {
  description = "Enable IPv6 support for the attachment"
  type        = string
  default     = "disable"
}
