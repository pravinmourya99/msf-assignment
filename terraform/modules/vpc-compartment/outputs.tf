output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, s in aws_subnet.this : k => s.id }
}

output "subnet_ids_by_type" {
  description = "Map of subnet type to list of subnet IDs"
  value = {
    for type in distinct([for s in var.subnets : s.type]) :
    type => [for s in var.subnets : aws_subnet.this[s.name].id if s.type == type]
  }
}

output "private_route_table_ids" {
  description = "Map of subnet name to private route table ID (for adding TGW routes)"
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}

output "public_route_table_id" {
  description = "ID of the public route table (if any)"
  value       = local.has_public ? aws_route_table.public[0].id : null
}

output "interfacing_subnet_ids" {
  description = "List of interfacing subnet IDs (for TGW attachment)"
  value = [
    for s in var.subnets : aws_subnet.this[s.name].id
    if s.type == "interfacing"
  ]
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway key to ID"
  value       = { for k, nat in aws_nat_gateway.this : k => nat.id }
}

output "security_group_ids" {
  description = "Map of type to security group ID"
  value = merge(
    var.enable_security_groups && local.has_public ? { "public" = aws_security_group.public[0].id } : {},
    { for k, sg in aws_security_group.by_type : k => sg.id }
  )
}

output "compartment_name" {
  description = "Compartment name"
  value       = var.compartment_name
}

output "has_public_subnets" {
  description = "Whether this compartment has public subnets"
  value       = local.has_public
}
