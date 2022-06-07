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

# Resources
resource "aws_s3_bucket" "s3bucket1" {
  bucket = "${var.product}-${var.bucket_name}-${var.deployment_identifier}"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.s3bucket1.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}