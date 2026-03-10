variable "name_prefix" {
  description = "Prefix for resource names (e.g. project-env)"
  type        = string
}

variable "compartment_name" {
  description = "Name of the compartment (e.g. internet, gen, workload-x)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create. Each must have name, cidr, availability_zone, type (public|firewall|interfacing|web|compute|data)"
  type = list(object({
    name               = string
    cidr               = string
    availability_zone  = string
    type               = string
  }))
}

variable "enable_internet_gateway" {
  description = "Whether to create an Internet Gateway (for compartments with public subnets)"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway(s) in public subnet(s)"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost-saving for dev)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_security_groups" {
  description = "Whether to create security groups per subnet role"
  type        = bool
  default     = true
}
