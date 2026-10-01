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
