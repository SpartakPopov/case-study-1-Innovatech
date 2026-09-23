resource "aws_subnet" "tgw_attach" {
  vpc_id            = aws_vpc.innovatech.id
  cidr_block        = "10.0.1.192/26"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "innovatech-tgw-attach-subnet"
  }
}

resource "aws_route_table" "tgw_attach_rt" {
  vpc_id = aws_vpc.innovatech.id
  tags = {
    Name = "innovatech-tgw-attach-rt"
  }
}

resource "aws_route" "tgw_attach_default" {
  route_table_id         = aws_route_table.tgw_attach_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.innovatech_nat.id
}

resource "aws_route_table_association" "tgw_attach_assoc" {
  subnet_id      = aws_subnet.tgw_attach.id
  route_table_id = aws_route_table.tgw_attach_rt.id
}

resource "aws_ec2_transit_gateway_route" "default_via_dmz" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dmz_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.innovatech_tgw.association_default_route_table_id
}