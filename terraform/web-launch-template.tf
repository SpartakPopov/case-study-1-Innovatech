resource "aws_launch_template" "web_lt" {
    name_prefix   = "innovatech-web-"
    image_id      = "ami-0669b163befffbdfc" # Amazon Linux 2023, eu-central-1 - verify this is current before applying
    instance_type = "t3.micro"

    iam_instance_profile {
        name = aws_iam_instance_profile.ec2_ssm_profile.name
    }

    vpc_security_group_ids = [aws_security_group.web_sg.id]

    user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Innovatech Web Tier - $(hostname)</h1>" > /usr/share/nginx/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "innovatech-web"
    }
  }

  tags = {
    Name = "innovatech-web-lt"
  }
}