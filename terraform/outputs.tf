# Used by the pipeline's post-apply verification (.github/scripts/verify.sh)

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.web_tg.arn
}

output "asg_min_size" {
  value = aws_autoscaling_group.web_asg.min_size
}
