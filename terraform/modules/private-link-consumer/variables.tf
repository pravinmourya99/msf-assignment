variable "name_prefix" {
  description = "Prefix for resource names (e.g. project-env)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the endpoint will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC endpoint (typically private subnets)"
  type        = list(string)
}

variable "service_name" {
  description = "Service name of the VPC endpoint service (e.g. com.amazonaws.region.vpce-svc-xxx)"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the VPC endpoint"
  type        = list(string)
  default     = []
}

variable "private_dns_enabled" {
  description = "Whether to associate a private hosted zone with the endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "endpoint_suffix" {
  description = "Suffix for the endpoint name (e.g. api, dynamodb)"
  type        = string
  default     = "consumer"
}
