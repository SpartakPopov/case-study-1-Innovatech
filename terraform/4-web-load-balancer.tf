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
