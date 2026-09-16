resource "aws_vpc" "innovatechmanagement" {
    cidr_block = "10.0.4.0/24"
    tags = {
        Name = "innovatech-management-vpc"
    }
  
}

resource "aws_subnet" "management" {
    vpc_id                  = aws_vpc.innovatechmanagement.id
    cidr_block              = "10.0.4.0/25"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "innovatech-management-subnet"
    }
}