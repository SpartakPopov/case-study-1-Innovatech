resource "aws_vpc" "innovatechweb" {
    cidr_block = "10.0.2.0/24"

    tags = {
        Name = "innovatech-web-vpc"
    }
}

resource "aws_subnet" "web_a" {
    vpc_id                  = aws_vpc.innovatechweb.id
    cidr_block              = "10.0.2.0/25"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "innovatech-web-subnet-a"
    }
}

resource "aws_subnet" "web_b" {
    vpc_id                  = aws_vpc.innovatechweb.id
    cidr_block              = "10.0.2.128/25"
    availability_zone       = "eu-central-1b"

    tags = {
        Name = "innovatech-web-subnet-b"
    }
}