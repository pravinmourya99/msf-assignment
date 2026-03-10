resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support  = var.dns_support
  ipv6_support = var.ipv6_support

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-tgw-attach-${var.compartment_name}"
    Compartment = var.compartment_name
  })
}
