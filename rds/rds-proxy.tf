data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/iam/terraform.tfstate"
    region = var.backend_region
  }
}

resource "aws_db_proxy" "db_proxy1" {
  name                   = "${var.product}-rds-proxy-${var.deployment_identifier}"
  debug_logging          = false
  engine_family          = var.engine_family
  idle_client_timeout    = 300
  require_tls            = true
  role_arn               = data.terraform_remote_state.iam.outputs.rds_proxy_iam_role
  vpc_security_group_ids = [aws_security_group.nsg_rds.0.id]
  vpc_subnet_ids         = data.terraform_remote_state.network.outputs.vpc["private_subnet_ids"]

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = module.rds_secret.secrets_manager["arn"]
  }

  tags = var.tags

  depends_on = [aws_db_instance.rds1]
}

resource "aws_db_proxy_default_target_group" "rds_tg" {
  db_proxy_name = aws_db_proxy.db_proxy1.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "rds_target1" {
  db_instance_identifier = aws_db_instance.rds1.0.id
  db_proxy_name          = aws_db_proxy.db_proxy1.name
  target_group_name      = aws_db_proxy_default_target_group.rds_tg.name
}