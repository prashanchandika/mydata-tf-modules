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
    acc_id              = "${data.aws_caller_identity.current.account_id}"
}