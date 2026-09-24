resource "aws_autoscaling_group" "web_asg" {
  name                      = "innovatech-web-asg"
  vpc_zone_identifier       = [aws_subnet.web_a.id, aws_subnet.web_b.id]


  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
 
        health_check_type         = "ELB"
        health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "innovatech-web"
    propagate_at_launch = true
  }
}