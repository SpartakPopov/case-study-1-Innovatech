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
    Name = "innovatech-alb-sg"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "innovatech-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.innovatech.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "innovatech-web-tg"
  }
}


resource "aws_lb" "web_alb" {
  name               = "innovatech-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.dmz_public_a.id, aws_subnet.dmz_public_b.id]

  tags = {
    Name = "innovatech-web-alb"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}