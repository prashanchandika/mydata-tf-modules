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

data "aws_availability_zones" "available" {
  state = "available"
}


################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../full-network"

  region = "${var.region}"

  name = "${var.product}-${var.deployment_identifier}-network"
  vpc_cidr = "${var.vpc_cidr}"

#  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  enable_ipv6 = true

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true

  public_subnet_tags = merge (
    var.tags,
    { 
      Name = "${var.product}-${var.deployment_identifier}-public-subnet" 
    },
  )

  tags = var.tags

  vpc_tags = merge (
    var.tags,
    { 
      Name = "${var.product}-${var.deployment_identifier}-vpc" 
    },
  )

}