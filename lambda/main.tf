terraform {
  backend "s3" {}
  required_version = "= 1.1.7"

  required_providers {
    aws = "= 4.2.0"
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}


locals {
    acc_id              = "${data.aws_caller_identity.current.account_id}"
    private_subnet_ids  = "${data.terraform_remote_state.network.outputs.vpc["private_subnet_ids"]}"
    public_subnet_ids   = "${data.terraform_remote_state.network.outputs.vpc["public_subnet_ids"]}"
    vpc_id              = "${data.terraform_remote_state.network.outputs.vpc["id"]}"
    vpc_cidr            = "${data.terraform_remote_state.network.outputs.vpc["cidr"]}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
    region = var.backend_region
  }
}

data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/${var.sub_product}/rds/terraform.tfstate"
    region = var.backend_region
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/iam/terraform.tfstate"
    region = var.backend_region
  }
}

resource "aws_lambda_function" "lambda1" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "${path.module}/templates/function.zip"
  function_name = "${var.product}-${var.lambda_name}-${var.deployment_identifier}"
  role          = data.terraform_remote_state.iam.outputs.lambda_iam_role
  handler       = var.handler

  #s3_bucket = var.s3_bucket
  #s3_key    = var.s3_key
  timeout = 300
  memory_size = 512
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #source_code_hash = filebase64sha256("lambda_function_payload.zip")




  runtime = var.runtime

  environment {
    variables = {
      DB_SECRETS_NAME = data.terraform_remote_state.rds.outputs.db_seret_name
      ENV_LOG_TO_SYSTEM_OUT = true
      ENV_USE_CRON_TO_LOAD_WAREHOUSE = true
    }
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = local.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = var.tags
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.product}-${var.lambda_name}-${var.deployment_identifier}-lambda-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id.0

  ingress {
    description      = "Allow traffic into lambda on port ${var.lambda_port}"
    from_port        = var.lambda_port
    to_port          = var.lambda_port
    protocol         = "tcp"
    cidr_blocks      = [local.vpc_cidr]
  #  ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}