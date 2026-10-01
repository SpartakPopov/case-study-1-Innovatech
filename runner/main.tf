terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "innovatech-tfstate-453809273733"
    key          = "runner/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_vpc" "internal" {
  filter {
    name   = "tag:Name"
    values = ["innovatech-internal-vpc"]
  }
}

data "aws_subnet" "monitoring" {
  filter {
    name   = "tag:Name"
    values = ["innovatech-monitoring-subnet"]
  }
}

resource "aws_security_group" "runner" {
  name        = "innovatech-runner-sg"
  description = "CI runner - outbound only, no inbound"
  vpc_id      = data.aws_vpc.internal.id

  egress {
    description = "All outbound (GitHub, AWS APIs, Terraform downloads)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "innovatech-runner-sg"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "runner" {
  name = "ci-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "runner_poweruser" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "runner_iam_scoped" {
  name = "innovatech-iam-scoped"
  role = aws_iam_role.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole", "iam:UntagRole",
        "iam:UpdateAssumeRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
        "iam:PutRolePolicy", "iam:GetRolePolicy", "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy", "iam:DetachRolePolicy",
        "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile",
        "iam:TagInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
        "iam:ListInstanceProfilesForRole", "iam:PassRole"
      ]
      Resource = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/innovatech-*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/innovatech-*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "runner" {
  name = "ci-runner-profile"
  role = aws_iam_role.runner.name
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "runner" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.small"
  subnet_id              = data.aws_subnet.monitoring.id
  vpc_security_group_ids = [aws_security_group.runner.id]
  iam_instance_profile   = aws_iam_instance_profile.runner.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    dnf install -y git jq unzip tar libicu

    TF_VERSION="1.15.6"
    curl -sSfL --retry 5 -o /tmp/terraform.zip \
      https://releases.hashicorp.com/terraform/$${TF_VERSION}/terraform_$${TF_VERSION}_linux_amd64.zip
    unzip -o /tmp/terraform.zip -d /usr/local/bin/

    useradd --create-home runner
    RUNNER_VERSION=$(curl -sSf --retry 5 https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//')
    mkdir -p /home/runner/actions-runner
    cd /home/runner/actions-runner
    curl -sSfL --retry 5 -o runner.tar.gz \
      https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
    tar xzf runner.tar.gz
    chown -R runner:runner /home/runner/actions-runner

    PAT=$(aws ssm get-parameter --region eu-central-1 --name /innovatech/ci/github-pat \
      --with-decryption --query Parameter.Value --output text)
    REG_TOKEN=$(curl -sSf -X POST \
      -H "Authorization: Bearer $PAT" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/SpartakPopov/case-study-1-Innovatech/actions/runners/registration-token \
      | jq -r .token)

    sudo -u runner ./config.sh --unattended --replace \
      --url https://github.com/SpartakPopov/case-study-1-Innovatech \
      --token "$REG_TOKEN" \
      --name innovatech-runner \
      --labels innovatech

    ./svc.sh install runner
    ./svc.sh start
  EOF

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "innovatech-ci-runner"
  }
}

output "runner_instance_id" {
  value = aws_instance.runner.id
}

