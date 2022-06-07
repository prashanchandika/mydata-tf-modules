data "template_file" "rds_proxy_policy" {
  template = file("${path.module}/templates/rds_proxy_policy.json")

  vars = {
    region         = var.region
    acc_id         = local.acc_id
    environment    = var.deployment_identifier
    product        = var.product
  }
}

resource "aws_iam_policy" "rds_proxy_policy" {
  name   =  "${var.product}-${var.deployment_identifier}-rds-proxy-policy"
  policy = data.template_file.rds_proxy_policy.rendered

  tags = var.tags
}

resource "aws_iam_role" "rds_proxy_role" {
  name = "${var.product}-${var.deployment_identifier}-rds-proxy-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "rds.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "rds_proxy_attach" {
  role       = aws_iam_role.rds_proxy_role.name
  policy_arn = aws_iam_policy.rds_proxy_policy.arn
}