
resource "aws_route" "dmz_to_internal" {
  route_table_id         = aws_route_table.dmz_public_a_rt.id
  destination_cidr_block = "10.0.2.0/23"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "internal_to_dmz" {
  route_table_id         = aws_vpc.internal.default_route_table_id
  destination_cidr_block = "10.0.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}