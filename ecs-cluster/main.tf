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
}


resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0

  name = "${var.product}-${var.sub_product}-${var.deployment_identifier}-cluster"

  capacity_providers = var.capacity_providers
/* 
  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy

    content {
      capacity_provider = strategy.value["capacity_provider"]
      weight            = lookup(strategy.value, "weight", 100)
      base              = lookup(strategy.value, "base", 1)
    }
  } */

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}
