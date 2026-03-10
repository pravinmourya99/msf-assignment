resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.create_default_security_group ? [aws_security_group.vpce[0].id] : var.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpce-${var.endpoint_suffix}"
  })
}

# Default security group for the endpoint if none provided (allow HTTPS from VPC CIDR)
resource "aws_security_group" "vpce" {
  count = var.create_default_security_group ? 1 : 0

  name        = "${var.name_prefix}-vpce-${var.endpoint_suffix}-sg"
  description = "Security group for PrivateLink consumer endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpce-${var.endpoint_suffix}-sg"
  })
}

data "aws_vpc" "this" {
  id = var.vpc_id
}
