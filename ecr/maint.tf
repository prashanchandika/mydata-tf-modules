resource "aws_ecr_repository" "ecr1" {
  name                 = "${var.ecr_name}"
  image_tag_mutability = "MUTABLE"

  tags          = "${var.tags}"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}