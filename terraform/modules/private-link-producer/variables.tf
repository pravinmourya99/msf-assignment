variable "name_prefix" {
  description = "Prefix for resource names (e.g. project-env)"
  type        = string
}

variable "compartment_name" {
  description = "Name of the compartment (e.g. workload-z)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the NLB and endpoint service will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the NLB (typically private subnets - e.g. compute or interfacing)"
  type        = list(string)
}

variable "allowed_principals" {
  description = "List of ARNs (e.g. account root, IAM role) allowed to connect to the endpoint service"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "service_suffix" {
  description = "Suffix for the endpoint service name (e.g. api)"
  type        = string
  default     = "api"
}

# Optional: pass an existing NLB ARN instead of creating one (e.g. in front of ALB)
variable "existing_nlb_arn" {
  description = "ARN of an existing NLB to expose as the endpoint service (if set, NLB is not created)"
  type        = string
  default     = null
}
