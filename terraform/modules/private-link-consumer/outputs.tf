output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint"
  value       = aws_vpc_endpoint.this.id
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the VPC endpoint"
  value       = aws_vpc_endpoint.this.dns_entry
}

output "vpc_endpoint_private_dns_enabled" {
  description = "Whether private DNS is enabled"
  value       = aws_vpc_endpoint.this.private_dns_enabled
}
