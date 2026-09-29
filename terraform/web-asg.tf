resource "aws_autoscaling_group" "web_asg" {
  name                = "innovatech-web-asg"
  vpc_zone_identifier = [aws_subnet.web_a.id, aws_subnet.web_b.id]

  max_size         = 4
  min_size         = 2
  desired_capacity = 2

  depends_on = [
    aws_cloudwatch_event_target.asg_lifecycle_to_lambda,
    aws_lambda_permission.allow_eventbridge,
  ]


  # A concrete version number (not "$Latest") so a launch template change is a
  # change to the ASG, which is what triggers the instance refresh below.
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = aws_launch_template.web_lt.latest_version
  }

  # Rolling replacement when the launch template changes, keeping half the fleet serving.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  health_check_type         = "ELB"
  health_check_grace_period = 60

  initial_lifecycle_hook {
    name                 = "innovatech-web-launching-hook"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    heartbeat_timeout    = 120
    default_result       = "ABANDON"
  }

  initial_lifecycle_hook {
    name                 = "innovatech-web-terminating-hook"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    heartbeat_timeout    = 120
    default_result       = "CONTINUE"
  }

  tag {
    key                 = "Name"
    value               = "innovatech-web"
    propagate_at_launch = true
  }


}