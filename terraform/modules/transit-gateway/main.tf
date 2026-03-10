resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tgw"
  })
}
