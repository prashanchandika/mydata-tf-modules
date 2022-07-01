provider "aws" {
region="${var.region}"
}

terraform {
  backend "s3" {}
  required_version = "= 1.1.7"

  required_providers {
    aws = "= 4.2.0"
  }
}

data "aws_caller_identity" "current" {}

locals {
  acc_id = "${data.aws_caller_identity.current.account_id}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
    region = var.backend_region
  }
}

resource "aws_db_instance" "rds1" {
  count      = var.create_rds ? 1 : 0

  allocated_storage   = var.allocated_storage
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  db_name             = "${var.rds_name}"
  identifier          = "${var.product}-${var.deployment_identifier}"
  username            = var.username
  password            = var.password
  parameter_group_name  = aws_db_parameter_group.pg1.name
  skip_final_snapshot = var.skip_final_snapshot

  publicly_accessible = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.subnet_rds.0.id
  vpc_security_group_ids = [aws_security_group.nsg_rds.0.id]
  tags                = var.tags
}


resource "aws_db_subnet_group" "subnet_rds" {
  count      = var.create_rds ? 1 : 0
  
  name       = "${var.product}-${var.deployment_identifier}-subnetgroup"
  subnet_ids = data.terraform_remote_state.network.outputs.vpc["public_subnet_ids"]
  tags = var.tags
}

resource "aws_db_parameter_group" "pg1" {
  name   = "${var.product}-${var.deployment_identifier}-parametergroup"
  family = "postgres12"

  parameter {
    apply_method = "pending-reboot"
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pg_cron"
  }

}


#Security Group for RDS
resource "aws_security_group" "nsg_rds" {
  count       = var.create_rds ? 1 : 0

  name        = "${var.product}-${var.deployment_identifier}-rds-sg"
  description = "Allow connections on DB Port"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id[0]
  
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group_rule" "nsg_rds_ingress_rule" {
  count      = var.create_rds ? 1 : 0

  description              = "Allow connections on DB Port"
  type                     = "ingress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_rds.0.id
}

resource "aws_security_group_rule" "nsg_rds_egress_rule" {
  count      = var.create_rds ? 1 : 0

  description              = "Allow connections on DB Port"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_rds.0.id
}

# Secret
data "template_file" "rds_secrets" {
  template = file("${path.module}/templates/secret.json")

  vars = {
  username            = aws_db_instance.rds1.0.username
  password            = aws_db_instance.rds1.0.password
  engine              = aws_db_instance.rds1.0.engine
  port                = aws_db_instance.rds1.0.port
  dbInstanceIdentifier  = aws_db_instance.rds1.0.identifier
  dbname              = aws_db_instance.rds1.0.db_name
  proxyhost           = aws_db_proxy.db_proxy1.endpoint
  }
}

module "rds_secret" {
  source              = "../secrets-manager"
  secret_name         = "${var.product}-${var.deployment_identifier}-rds-sm"
  secret_string       = data.template_file.rds_secrets.rendered
  tags                = var.tags
}