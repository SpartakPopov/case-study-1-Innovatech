resource "aws_security_group" "management_sg" {
  name        = "innovatech-management-sg"
  description = "Management/monitoring tier - no inbound needed (SSM is outbound-initiated)"
  vpc_id      = aws_vpc.internal.id

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "innovatech-management-sg"
  }
}