resource "aws_instance" "db" {
  ami                    = "ami-0669b163befffbdfc" # Amazon Linux 2023, eu-central-1 - verify this is current before applying
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.data.id
  vpc_security_group_ids = [aws_security_group.data_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
    sed -i 's#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql-2022#gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql-2023#' /etc/yum.repos.d/mysql-community.repo
    dnf install -y mysql-community-server
    systemctl enable --now mysqld

    until grep -q 'temporary password' /var/log/mysqld.log 2>/dev/null; do sleep 2; done
    TEMP_PW=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

    mysql --connect-expired-password -u root -p"$TEMP_PW" <<SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'Innovatech2025!';
    CREATE DATABASE innovatech;
    CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppUserPass2025!';
    GRANT ALL PRIVILEGES ON innovatech.* TO 'appuser'@'%';
    FLUSH PRIVILEGES;
    USE innovatech;
    CREATE TABLE visits (id INT AUTO_INCREMENT PRIMARY KEY, hit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
    SQL

    sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf 2>/dev/null || echo "bind-address = 0.0.0.0" >> /etc/my.cnf
    systemctl restart mysqld



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

  tags = {
    Name = "innovatech-db"
  }
}