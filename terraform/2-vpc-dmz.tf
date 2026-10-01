resource "aws_vpc" "innovatech" {
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "innovatech-dmz"
  }
}

resource "aws_subnet" "dmz_public_a" {
  vpc_id                  = aws_vpc.innovatech.id
  cidr_block              = "10.0.1.0/26"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "innovatech-dmz-public-subnet"
  }
}

resource "aws_subnet" "dmz_public_b" {
  vpc_id                  = aws_vpc.innovatech.id
  cidr_block              = "10.0.1.64/26"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "innovatech-dmz-public-subnet-b"
  }
}

resource "aws_subnet" "nat" {
  vpc_id                  = aws_vpc.innovatech.id
  cidr_block              = "10.0.1.128/26"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "innovatech-nat-subnet"
  }
}

resource "aws_internet_gateway" "innovatech_igw" {
  vpc_id = aws_vpc.innovatech.id
  tags = {
    Name = "innovatech-igw"
  }
}


resource "aws_route_table_association" "dmz_public_assoc" {
  subnet_id      = aws_subnet.dmz_public_a.id
  route_table_id = aws_route_table.dmz_public_a_rt.id
}

resource "aws_route_table_association" "dmz_public_b_assoc" {
  subnet_id      = aws_subnet.dmz_public_b.id
  route_table_id = aws_route_table.dmz_public_a_rt.id
}

resource "aws_route_table_association" "nat_assoc" {
  subnet_id      = aws_subnet.nat.id
  route_table_id = aws_route_table.dmz_public_a_rt.id
}