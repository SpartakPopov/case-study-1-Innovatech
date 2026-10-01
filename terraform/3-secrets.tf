
resource "random_password" "db_root" {
  length           = 24
  special          = true
  override_special = "_-"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "random_password" "db_app" {
  length           = 24
  special          = true
  override_special = "_-"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "random_password" "grafana_admin" {
  length           = 24
  special          = true
  override_special = "_-"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_ssm_parameter" "db_root_password" {
  name  = "/innovatech/db/root-password"
  type  = "SecureString"
  value = random_password.db_root.result
}

resource "aws_ssm_parameter" "db_app_password" {
  name  = "/innovatech/db/app-password"
  type  = "SecureString"
  value = random_password.db_app.result
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/innovatech/grafana/admin-password"
  type  = "SecureString"
  value = random_password.grafana_admin.result
}
