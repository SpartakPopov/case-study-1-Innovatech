resource "aws_route_table" "dmz_public_a_rt" {
  vpc_id = aws_vpc.innovatech.id
  tags = {
    Name = "innovatech-dmz-public-rt"
  }
}

resource "aws_route" "dmz_default" {
  route_table_id         = aws_route_table.dmz_public_a_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.innovatech_igw.id
}