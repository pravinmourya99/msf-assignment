output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.transit_gateway.tgw_id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = module.transit_gateway.tgw_arn
}

output "vpc_compartment_ids" {
  description = "Map of compartment name to VPC ID"
  value       = { for k, v in module.vpc_compartment : k => v.vpc_id }
}

output "vpc_compartment_cidrs" {
  description = "Map of compartment name to VPC CIDR (for building tgw_routes)"
  value       = { for k, v in module.vpc_compartment : k => v.vpc_cidr_block }
}

output "tgw_attachment_ids" {
  description = "Map of compartment name to TGW attachment ID"
  value       = { for k, v in module.tgw_attachment : k => v.attachment_id }
}

output "privatelink_producer_service_names" {
  description = "Map of producer compartment to PrivateLink service name (for consumers)"
  value       = { for k, v in module.privatelink_producer : k => v.service_name }
}

output "privatelink_consumer_endpoint_ids" {
  description = "Map of consumer key to VPC endpoint ID"
  value       = { for k, v in module.privatelink_consumer : k => v.vpc_endpoint_id }
}

output "subnet_ids_by_compartment" {
  description = "Map of compartment to subnet IDs by type"
  value       = { for k, v in module.vpc_compartment : k => v.subnet_ids_by_type }
}
