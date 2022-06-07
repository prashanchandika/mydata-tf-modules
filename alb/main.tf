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
  vpc_id              =  "${data.terraform_remote_state.network.outputs.vpc["id"]}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
    region = var.backend_region
  }
}


resource "aws_lb" "alb1" {
  name               = var.internal ? "${var.product}-${var.sub_product}-${var.deployment_identifier}-internal-alb" : "${var.product}-${var.sub_product}-${var.deployment_identifier}-alb"
  internal           = "${var.internal}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
#  subnets            = [for subnet in aws_subnet.public : subnet.id]
  subnets            = var.internal ? local.private_subnet_ids : local.public_subnet_ids

  enable_deletion_protection = false

/*   access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  } */
  depends_on  = [aws_security_group.lb_sg]
  tags = var.tags
}

# Security group rules
resource aws_security_group "lb_sg" {
  name        = var.internal ? "${var.product}-${var.sub_product}-${var.deployment_identifier}-internal-lb-sg" : "${var.product}-${var.sub_product}-${var.deployment_identifier}-external-lb-sg"
  description = "Allow connections through ALB"
  vpc_id      = local.vpc_id[0]
  tags = var.tags
}


resource "aws_security_group_rule" "sg_lb_egress_rule" {
  description              = "Allow connections through ALB"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id        = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "sg_lb_ingress_rule" {
  description              = "Allow connections through ALB"
  type                     = "ingress"
  from_port                = "${var.lb_from_port}"
  to_port                  = "${var.lb_to_port}"
  protocol                 = "tcp"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}


resource "aws_security_group_rule" "sg_lb_ingress_rule_http" {
  count                    = var.internal ? 0 : 1

  description              = "Allow http connections through ALB"
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "sg_lb_ingress_rule_https" {
  count                    = var.internal ? 0 : 1

  description              = "Allow https connections through ALB"
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}


# Fixed response http listener

/* 
Listener removed from ALB creation because gateway is set to listen on 80

resource "aws_alb_listener" "lis_http" {

  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
} */