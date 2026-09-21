resource "aws_security_group" "data_sg" {
  name        = "innovatech-data-sg"
  description = "Allow DB traffic from Web tier and metrics scraping from Management"
  vpc_id      = aws_vpc.internal.id

  ingress {
    description     = "MySQL from Web tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
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
    Name = "innovatech-data-sg"
  }
}