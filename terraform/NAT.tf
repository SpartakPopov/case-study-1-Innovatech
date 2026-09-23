resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "innovatech-nat-eip"
  }
}

resource "aws_nat_gateway" "innovatech_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat.id

  tags = {
    Name = "innovatech-nat-gw"
  }

  depends_on = [aws_internet_gateway.innovatech_igw]
}

resource "aws_route" "internal_default" {
  route_table_id         = aws_vpc.internal.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.innovatech_tgw.id
}