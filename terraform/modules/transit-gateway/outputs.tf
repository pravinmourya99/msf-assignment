output "tgw_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "tgw_association_default_route_table_id" {
  description = "ID of the default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "tgw_propagation_default_route_table_id" {
  description = "ID of the default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}
