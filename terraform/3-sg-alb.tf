resource "aws_security_group" "alb_sg" {
  name        = "innovatech-alb-sg"
  description = "Allow inbound HTTP from internet to ALB"
  vpc_id      = aws_vpc.innovatech.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "innovatech-web-alb"
    ManagedBy = "terraform-pipeline"
  }
}
