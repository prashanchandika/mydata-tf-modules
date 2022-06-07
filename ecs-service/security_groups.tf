
# Security groups and rules

data "aws_lb" "service_alb" {
  arn  = "${var.alb_arn}"
#  name = "myp2-test-internal-alb"
}


# Service SG
resource "aws_security_group" "nsg_service" {
  name        = "${var.service_name}-${var.deployment_identifier}-sg"
  description = "Allow connections from ALB ${var.service_name}-${var.deployment_identifier}-lb to service"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "nsg_service_ingress_rule" {

  for_each  = data.aws_lb.service_alb.security_groups


  description              = "Only allow SG ${var.service_name}-${var.deployment_identifier}-lb to connect to ${var.service_name}-${var.deployment_identifier}-task on port ${var.service_port}"
  type                     = "ingress"
  from_port                = "${var.service_port}"
  to_port                  = "${var.service_port}"
  protocol                 = "tcp"
#  source_security_group_id = aws_security_group.nsg_lb.id
  source_security_group_id = each.value
#  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_service.id
}

resource "aws_security_group_rule" "nsg_service_egress_rule" {
  description              = "Allow All out from ${var.service_name}-${var.deployment_identifier}-task"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
#  source_security_group_id = aws_security_group.nsg_task.id
  cidr_blocks              =  ["0.0.0.0/0"]
  security_group_id        = aws_security_group.nsg_service.id
}