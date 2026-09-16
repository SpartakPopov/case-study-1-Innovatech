resource "aws_vpc" "innovatechdata" {
    cidr_block = "10.0.3.0/24"
    tags = {
        Name = "innovatech-data-vpc"
    }
}

resource "aws_subnet" "data" {
    vpc_id                  = aws_vpc.innovatechdata.id
    cidr_block              = "10.0.3.0/25"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "innovatech-data-subnet"
    }
}