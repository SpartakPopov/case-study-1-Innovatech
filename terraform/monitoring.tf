resource "aws_iam_role" "monitoring_role" {
  name = "innovatech-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_policy_attachment" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "monitoring_policy" {
  name = "innovatech-monitoring-policy"
  role = aws_iam_role.monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "monitoring_instance_profile" {
  name = "innovatech-monitoring-instance-profile"
  role = aws_iam_role.monitoring_role.name
}


resource "aws_instance" "monitoring" {
  ami                    = "ami-0669b163befffbdfc" # Amazon Linux 2023, eu-central-1 - verify this is current before applying
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.monitoring.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.monitoring_instance_profile.name


  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    # --- Prometheus ---
    VER="3.15.0"
    cd /tmp
    curl -sSfL --retry 10 --retry-delay 10 --retry-all-errors -O https://github.com/prometheus/prometheus/releases/download/v$${VER}/prometheus-$${VER}.linux-amd64.tar.gz
    tar xzf prometheus-$${VER}.linux-amd64.tar.gz
    cp prometheus-$${VER}.linux-amd64/prometheus prometheus-$${VER}.linux-amd64/promtool /usr/local/bin/
    useradd --no-create-home --shell /sbin/nologin prometheus

    mkdir -p /etc/prometheus /var/lib/prometheus
    echo "${base64encode(file("${path.module}/prometheus.yml"))}" | base64 -d > /etc/prometheus/prometheus.yml
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

    cat > /etc/systemd/system/prometheus.service <<'UNIT'
    [Unit]
    Description=Prometheus
    After=network-online.target
    Wants=network-online.target

    [Service]
    User=prometheus
    ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus --storage.tsdb.retention.time=15d
    Restart=always

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now prometheus

        # --- Grafana ---
    cat > /etc/yum.repos.d/grafana.repo <<'REPO'
    [grafana]
    name=grafana
    baseurl=https://rpm.grafana.com
    repo_gpgcheck=1
    enabled=1
    gpgcheck=1
    gpgkey=https://rpm.grafana.com/gpg.key
    sslverify=1
    sslcacert=/etc/pki/tls/certs/ca-bundle.crt
    REPO

    dnf install -y grafana

    mkdir -p /etc/grafana/provisioning/datasources
    echo "${base64encode(file("${path.module}/grafana.yml"))}" | base64 -d > /etc/grafana/provisioning/datasources/prometheus.yml
    chown -R root:grafana /etc/grafana/provisioning

    systemctl enable --now grafana-server

  EOF



  tags = {
    Name = "innovatech-monitoring"
  }


}


