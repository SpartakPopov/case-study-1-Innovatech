locals {
  nginx_php_conf = <<-CONF
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
  CONF

  index_php = <<-PHP
    <?php
    $cfg = parse_ini_file("/etc/innovatech/db.ini");
    $conn = new mysqli($cfg["host"], $cfg["user"], $cfg["password"], $cfg["name"]);
    if ($conn->connect_error) {
        die("<h1>Database connection failed: " . $conn->connect_error . "</h1>");
    }
    $conn->query("INSERT INTO visits () VALUES ()");
    $result = $conn->query("SELECT COUNT(*) AS total FROM visits");
    $row = $result->fetch_assoc();
    echo "<h1>Innovatech Web Tier</h1>";
    echo "<p>Served by instance: " . gethostname() . "</p>";
    echo "<p>Total visits recorded in database: " . $row['total'] . "</p>";
    $conn->close();
    ?>
  PHP
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "innovatech-web-"
  image_id      = "ami-0669b163befffbdfc"
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx php-fpm php-mysqlnd
    systemctl enable --now nginx
    systemctl enable --now php-fpm

    until DB_PW=$(aws ssm get-parameter --region eu-central-1 --name ${aws_ssm_parameter.db_app_password.name} --with-decryption --query Parameter.Value --output text); do sleep 5; done
    mkdir -p /etc/innovatech
    cat > /etc/innovatech/db.ini <<INI
    host = "${aws_instance.db.private_ip}"
    user = "appuser"
    password = "$DB_PW"
    name = "innovatech"
    INI
    chown root:apache /etc/innovatech/db.ini
    chmod 640 /etc/innovatech/db.ini

    mkdir -p /etc/nginx/default.d
    echo "${base64encode(local.nginx_php_conf)}" | base64 -d > /etc/nginx/default.d/php.conf
    echo "${base64encode(local.index_php)}" | base64 -d > /usr/share/nginx/html/index.php
    rm -f /usr/share/nginx/html/index.html

    systemctl restart nginx
    systemctl restart php-fpm




    NE_VERSION="1.8.2"
    cd /tmp
    curl -sLO https://github.com/prometheus/node_exporter/releases/download/v$${NE_VERSION}/node_exporter-$${NE_VERSION}.linux-amd64.tar.gz
    tar xzf node_exporter-$${NE_VERSION}.linux-amd64.tar.gz
    cp node_exporter-$${NE_VERSION}.linux-amd64/node_exporter /usr/local/bin/
    useradd --no-create-home --shell /sbin/nologin node_exporter

    cat > /etc/systemd/system/node_exporter.service <<'UNIT'
    [Unit]
    Description=Prometheus Node Exporter
    After=network.target

    [Service]
    User=node_exporter
    ExecStart=/usr/local/bin/node_exporter
    Restart=always

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now node_exporter
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