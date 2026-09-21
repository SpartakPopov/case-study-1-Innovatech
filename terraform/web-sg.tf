
resource "aws_security_group" "web_sg" {
  name        = "innovatech-web-sg"
  description = "Allow HTTP from ALB and metrics scraping from Management"
  vpc_id      = aws_vpc.internal.id

    ingress {
    description = "HTTP from ALB (DMZ subnets)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/26", "10.0.1.64/26"]
  }

  ingress {
    description     = "Node exporter metrics from Management (Prometheus scrape)"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.management_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "innovatech-web-sg"
  }
}

