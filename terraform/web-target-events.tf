resource "aws_cloudwatch_event_rule" "asg_lifecycle" {
  name        = "innovatech-asg-lifecycle"
  description = "Captures web ASG instance launch/terminate lifecycle actions"

  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail-type = ["EC2 Instance-launch Lifecycle Action", "EC2 Instance-terminate Lifecycle Action"]
    detail = {
      AutoScalingGroupName = [aws_autoscaling_group.web_asg.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "asg_lifecycle_to_lambda" {
  rule      = aws_cloudwatch_event_rule.asg_lifecycle.name
  target_id = "target-registration-lambda"
  arn       = aws_lambda_function.target_registration.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_registration.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.asg_lifecycle.arn
}