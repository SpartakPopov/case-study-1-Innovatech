data "archive_file" "target_registration_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/target_registration.py"
  output_path = "${path.module}/lambda_src/target_registration.zip"
}

resource "aws_iam_role" "lambda_target_reg_role" {
  name = "innovatech-lambda-target-reg-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_target_reg_policy" {
  name = "innovatech-lambda-target-reg-policy"
  role = aws_iam_role.lambda_target_reg_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"]
        Resource = aws_lb_target_group.web_tg.arn
      },
      {
        Effect   = "Allow"
        Action   = ["autoscaling:CompleteLifecycleAction"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "target_registration" {
  function_name    = "innovatech-target-registration"
  role             = aws_iam_role.lambda_target_reg_role.arn
  handler          = "target_registration.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.target_registration_zip.output_path
  source_code_hash = data.archive_file.target_registration_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      TARGET_GROUP_ARN = aws_lb_target_group.web_tg.arn
    }
  }
}