resource "aws_route" "dmz_to_web" {
    route_table_id         = aws_route_table.dmz_public_rt.id
    destination_cidr_block = "10.0.2.0/24"
    transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}
resource "aws_route" "web_to_dmz" {
    route_table_id         = aws_vpc.innovatechweb.default_route_table_id
    destination_cidr_block = "10.0.1.0/24"
    transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "web_to_data" {
  route_table_id         = aws_vpc.innovatechweb.default_route_table_id
  destination_cidr_block = "10.0.3.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "data_to_web" {
  route_table_id         = aws_vpc.innovatechdata.default_route_table_id
  destination_cidr_block = "10.0.2.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "mgmt_to_dmz" {
  route_table_id         = aws_vpc.innovatechmanagement.default_route_table_id
  destination_cidr_block = "10.0.1.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "mgmt_to_web" {
  route_table_id         = aws_vpc.innovatechmanagement.default_route_table_id
  destination_cidr_block = "10.0.2.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "mgmt_to_data" {
  route_table_id         = aws_vpc.innovatechmanagement.default_route_table_id
  destination_cidr_block = "10.0.3.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "dmz_to_mgmt" {
  route_table_id         = aws_route_table.dmz_public_rt.id
  destination_cidr_block = "10.0.4.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

 resource "aws_route" "web_to_mgmt" {
  route_table_id         = aws_vpc.innovatechweb.default_route_table_id
  destination_cidr_block = "10.0.4.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}

resource "aws_route" "data_to_mgmt" {
  route_table_id         = aws_vpc.innovatechdata.default_route_table_id
  destination_cidr_block = "10.0.4.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}