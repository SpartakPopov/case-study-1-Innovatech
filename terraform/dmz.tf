
resource "aws_vpc" "innovatech" {
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "innovatech-dmz"
  }
}
resource "aws_subnet" "dmz_public" {   
  vpc_id                  = aws_vpc.innovatech.id   // reference 
  cidr_block              = "10.0.1.0/25"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "innovatech-dmz-public-subnet"
  }
}

resource "aws_subnet" "dmz_nat" {
  vpc_id                  = aws_vpc.innovatech.id
  cidr_block              = "10.0.1.128/25"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "innovatech-dmz-nat-subnet"
  }
}

resource "aws_internet_gateway" "innovatech_igw" {
  vpc_id = aws_vpc.innovatech.id

  tags = {
    Name = "innovatech-igw"
  }
}

resource "aws_route_table" "dmz_public_rt" {
  vpc_id = aws_vpc.innovatech.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.innovatech_igw.id
  }

  tags = {
    Name = "innovatech-dmz-public-rt"
  }
}

resource "aws_route_table_association" "dmz_public_assoc" {
  subnet_id      = aws_subnet.dmz_public.id
  route_table_id = aws_route_table.dmz_public_rt.id
}

resource "aws_route_table_association" "dmz_nat_assoc" {
  subnet_id      = aws_subnet.dmz_nat.id
  route_table_id = aws_route_table.dmz_public_rt.id
}