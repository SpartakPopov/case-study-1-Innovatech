resource "aws_autoscaling_lifecycle_hook" "web_launching" {
  name                   = "innovatech-web-launching-hook"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = 120
  default_result         = "ABANDON"
}

resource "aws_autoscaling_lifecycle_hook" "web_terminating" {
  name                   = "innovatech-web-terminating-hook"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 120
  default_result         = "CONTINUE"
}