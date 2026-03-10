variable "name_prefix" {
  description = "Prefix for resource names (e.g. project-env)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Central hub for inter-VPC routing"
}

variable "default_route_table_association" {
  description = "Whether to associate attachments with the default route table"
  type        = string
  default     = "disable"
}

variable "default_route_table_propagation" {
  description = "Whether to propagate attachments to the default route table"
  type        = string
  default     = "disable"
}
