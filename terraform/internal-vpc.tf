resource "aws_vpc" "internal" {
  cidr_block = "10.0.2.0/23"
  tags = {
    Name = "innovatech-internal-vpc"
  }
}

resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.internal.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "innovatech-web-subnet-a"
  }
}

resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.internal.id
  cidr_block        = "10.0.2.128/25"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "innovatech-web-subnet-b"
  }
}

resource "aws_subnet" "data" {
  vpc_id            = aws_vpc.internal.id
  cidr_block        = "10.0.3.0/25"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "innovatech-data-subnet"
  }
}

resource "aws_subnet" "management" {
  vpc_id            = aws_vpc.internal.id
  cidr_block        = "10.0.3.128/25"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "innovatech-management-subnet"
  }
}