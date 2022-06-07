resource "aws_iam_role" "iam_for_ecs" {
  name = "${var.product}-ecs-execution-${var.deployment_identifier}-role"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  tags = var.tags
}



data "template_file" "ecs_execution_policy" {
  template = file("${path.module}/templates/ecs_execution_policy.json")

  vars = {
    region  = "${var.region}"
    acc_id  = local.acc_id
    product = "${var.product}"
  }
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name = "${var.product}-${var.deployment_identifier}-ecs-execution-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  policy  =  data.template_file.ecs_execution_policy.rendered

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.iam_for_ecs.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}