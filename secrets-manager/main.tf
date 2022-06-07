resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.secret_name}"
  recovery_window_in_days = 0
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = var.secret_string
}

