# NLB for PrivateLink - created only if existing_nlb_arn is not provided
# In production you would typically point this at an ALB or target group for your API
resource "aws_lb" "nlb" {
  count = var.existing_nlb_arn == null ? 1 : 0

  name               = "${replace(var.name_prefix, ".", "-")}-${var.compartment_name}-nlb-${var.service_suffix}"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.compartment_name}-nlb-${var.service_suffix}"
    Compartment = var.compartment_name
  })
}

# Dummy target group required for NLB (can be updated to point to ALB or instances later)
resource "aws_lb_target_group" "nlb" {
  count = var.existing_nlb_arn == null ? 1 : 0

  name     = "${replace(var.name_prefix, ".", "-")}-${var.compartment_name}-tg-${var.service_suffix}"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${var.compartment_name}-tg-${var.service_suffix}"
  })
}

# Listener so NLB is valid (targets can be added later - e.g. ALB or EC2)
resource "aws_lb_listener" "nlb" {
  count = var.existing_nlb_arn == null ? 1 : 0

  load_balancer_arn = aws_lb.nlb[0].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[0].arn
  }
}

locals {
  nlb_arn = coalesce(var.existing_nlb_arn, try(aws_lb.nlb[0].arn, null))
}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = length(var.allowed_principals) > 0 && var.allowed_principals[0] != "*"
  network_load_balancer_arns = [local.nlb_arn]
  # private_dns_name is optional; if set, requires Route53 verification

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.compartment_name}-vpc-endpoint-svc-${var.service_suffix}"
    Compartment = var.compartment_name
  })
}

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
  for_each = length(var.allowed_principals) > 0 && var.allowed_principals[0] != "*" ? toset(var.allowed_principals) : []

  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  principal_arn           = each.value
}
