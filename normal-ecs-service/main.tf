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
  acc_id = "${data.aws_caller_identity.current.account_id}"
  external_alb_arn              =  "${data.terraform_remote_state.external_alb.outputs.alb.arn}"
  ecs_cluster_id                =  "${data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_name}"
  ecs_service_prefix                =  "${data.terraform_remote_state.ecs_cluster.outputs.ecs_service_prefix}"
  common_envs                   =  [{"name": "GATEWAY_GRAPHQL", "value": "${data.terraform_remote_state.external_alb.outputs.alb.dns}/graphql"}]
  backend_hosts = [ 
    for service in var.backend_hosts: {
    "name": service, "value": "${data.terraform_remote_state.external_alb.outputs.alb.dns}" 
    }]
#  db_host                     = [{"name": "DB_HOST", "value": "${data.terraform_remote_state.rds.outputs.db_host.0}"}]
  db_host                     = [{"name": "DB_HOST", "valueFrom": "${data.terraform_remote_state.rds.outputs.db_seret_arn}:proxyhost::"}]
  db_user                     = [{"name": "DB_USER", "valueFrom": "${data.terraform_remote_state.rds.outputs.db_seret_arn}:username::"}]
  db_password                 = [{"name": "DB_PASSWORD", "valueFrom": "${data.terraform_remote_state.rds.outputs.db_seret_arn}:password::"}]

#parameters
  env_variables = [ 
    for env in var.env_variables: {
    "name": env.name, "valueFrom": "arn:aws:ssm:${var.region}:${local.acc_id}:parameter/${var.deployment_identifier}/${var.product}/${var.service_name}/${env.name}" 
    }]

}

#parameter store
resource "aws_ssm_parameter" "env_parameters" {
  for_each    = { 
    for env in var.env_variables : env.name => env
  }
  name        = "/${var.deployment_identifier}/${var.product}/${var.service_name}/${each.key}"
  description = ""
  type        = "SecureString"
  value       = "${each.value.value}"

  tags = var.tags
}
################################

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
    region = var.backend_region
  }
}

/* data "terraform_remote_state" "internal_alb" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/${var.sub_product}/alb-internal/terraform.tfstate"
    region = var.backend_region
  }
} */

data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/rds/terraform.tfstate"
    region = var.backend_region
  }
}


data "terraform_remote_state" "external_alb" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/${var.sub_product}/alb-external/terraform.tfstate"
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

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/iam/terraform.tfstate"
    region = var.backend_region
  }
}


module "ecs_service" {
  source = "../ecs-service"


  region = var.region
  deployment_identifier = "${var.deployment_identifier}"
#  alb_arn = "${var.alb_arn}"
#  alb_arn = var.external_service ? local.external_alb_arn : local.internal_alb_arn
  alb_arn = local.external_alb_arn
  tg_name = "${local.ecs_service_prefix}-${var.service_name_short}-${var.deployment_identifier}"
  tg_port = "${var.tg_port}"
  service_port = "${var.service_port}"
  listener_port = "${var.listener_port}"
  listener_protocol = "${var.listener_protocol}"
  certificate_arn   = var.certificate_arn
  vpc_id = data.terraform_remote_state.network.outputs.vpc.id[0]
  vpc_private_subnet_ids = data.terraform_remote_state.network.outputs.vpc["private_subnet_ids"]
  external_service = var.external_service
  acc_id = local.acc_id

# Service and Task related inputs ##############################
  service_name = "${local.ecs_service_prefix}-${var.service_name}"
#  service_image = "${var.service_image_repo}:${var.service_image_tag}"
  service_image = "${module.ecr_repo.ecr_url}:${var.service_image_tag}"
  service_command = "${var.service_command}"
  service_desired_count = "${var.service_desired_count}"
  service_deployment_maximum_percent = "${var.service_deployment_maximum_percent}"
  service_deployment_minimum_healthy_percent = "${var.service_deployment_minimum_healthy_percent}"
  service_role = "${var.service_role}"
  service_volumes = var.service_volumes
  task_cpu = var.task_cpu
  task_memory = var.task_memory
  ecs_cluster_id = local.ecs_cluster_id
  env_variables = concat(local.common_envs, local.backend_hosts)
  secrets    = concat(local.db_host, local.db_user, local.db_password, local.env_variables)
  task_exec_role = data.terraform_remote_state.iam.outputs.ecs_exec_iam_role
  enable_execute_command  = var.enable_execute_command 

#  Autoscalling related inputs
  scale_target_max_capacity = "${var.scale_target_max_capacity}"
  scale_target_min_capacity = "${var.scale_target_min_capacity}"
  min_cpu_threshold         = "${var.min_cpu_threshold}"
  max_cpu_threshold         = "${var.max_cpu_threshold}"
  memory_scale_target_value = "${var.memory_scale_target_value}"

# Just TAGS
  tags = "${var.tags}"
}



module "ecr_repo" {
  source        = "../ecr"
  ecr_name      = "${local.ecs_service_prefix}-${var.service_name}-${var.deployment_identifier}"
  scan_on_push  = "${var.scan_on_push}"
  tags          = "${var.tags}"

}

