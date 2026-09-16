resource "aws_ec2_transit_gateway" "innovatech_tgw" {
  description = "Innovatech Transit Gateway"
  tags = {
    Name = "innovatech-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dmz_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
  vpc_id = aws_vpc.innovatech.id
  subnet_ids = [aws_subnet.dmz_nat.id]

  tags = {
    Name = "innovatech-dmz-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "web_attachment" {
    transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
    vpc_id = aws_vpc.innovatechweb.id
    subnet_ids = [aws_subnet.web_a.id, aws_subnet.web_b.id]

    tags = {
        Name = "innovatech-web-tgw-attachment"
    }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "management_attachment" {
    transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
    vpc_id = aws_vpc.innovatechmanagement.id
    subnet_ids = [aws_subnet.management.id]

    tags = {
        Name = "innovatech-management-tgw-attachment"
    }
}
    
resource "aws_ec2_transit_gateway_vpc_attachment" "data_attachment" {
    transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
    vpc_id = aws_vpc.innovatechdata.id
    subnet_ids = [aws_subnet.data.id]

    tags = {
        Name = "innovatech-data-tgw-attachment"
    }
}