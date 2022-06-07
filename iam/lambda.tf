resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.product}-lambda-${var.deployment_identifier}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = var.tags
}

# policy for lambda

data "template_file" "lambda_policy" {
  template = file("${path.module}/templates/lambda_policy.json")

  vars = {
    region  = "${var.region}"
    acc_id  = local.acc_id
    product = "${var.product}"
  }
}



resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.product}-${var.deployment_identifier}-lambda-policy"
  role = aws_iam_role.iam_for_lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  policy  =  data.template_file.lambda_policy.rendered
}