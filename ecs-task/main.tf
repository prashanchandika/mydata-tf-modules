provider "aws" {
  region=var.region
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
    acc_id                        = "${data.aws_caller_identity.current.account_id}"
    ecs_cluster_id                =  "${data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_name}"
    ecs_service_prefix            =  "${data.terraform_remote_state.ecs_cluster.outputs.ecs_service_prefix}"
    vpc_private_subnet_ids        = ["${data.terraform_remote_state.network.outputs.vpc["private_subnet_ids"]}"]
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
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

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/${var.sub_product}/ecs-cluster/terraform.tfstate"
    region = var.backend_region
  }
}

/* resource "aws_security_group" "nsg_service" {
  name        = "${var.task_name}-${var.deployment_identifier}-sg"
  description = "Allow connections from ALB ${var.task_name}-${var.deployment_identifier}-lb to service"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id[0]

  tags = var.tags
} */

/* resource "null_resource" "ecstask" {
  provisioner "local-exec" {
    command = "aws ecs run-task --cluster ${local.ecs_cluster_id} --task-definition mydata-ftp-collector-dev-task:9 --launch-type FARGATE --count ${var.task_count} --network-configuration '{ \"awsvpcConfiguration\": { \"assignPublicIp\":\"DISABLED\", \"subnets\": ${local.vpc_private_subnet_ids}}}' --region ${var.region} --enable-execute-command"
    interpreter = ["/bin/bash", "-c"]
  }
} */


module "ecr_repo" {
  source        = "../ecr"
  ecr_name      = "${local.ecs_service_prefix}-${var.task_name}-${var.deployment_identifier}"
  scan_on_push  = "${var.scan_on_push}"
  tags          = "${var.tags}"

}
