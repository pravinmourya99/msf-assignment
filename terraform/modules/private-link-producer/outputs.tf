output "service_name" {
  description = "Service name for consumers to create VPC endpoints"
  value       = aws_vpc_endpoint_service.this.service_name
}

output "service_id" {
  description = "ID of the VPC endpoint service"
  value       = aws_vpc_endpoint_service.this.id
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer (created or existing)"
  value       = local.nlb_arn
}

output "target_group_arn" {
  description = "ARN of the target group (if NLB was created)"
  value       = try(aws_lb_target_group.nlb[0].arn, null)
}
