resource "aws_ec2_transit_gateway" "innovatech_tgw" {
  description = "Innovatech Transit Gateway"
  tags = {
    Name = "innovatech-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dmz_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
  vpc_id              = aws_vpc.innovatech.id
  subnet_ids          = [aws_subnet.tgw_attach.id]

  tags = {
    Name = "innovatech-dmz-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "internal_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.innovatech_tgw.id
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = [aws_subnet.web_a.id, aws_subnet.web_b.id]

  tags = {
    Name = "innovatech-internal-tgw-attachment"
  }
}