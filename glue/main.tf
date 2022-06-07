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


resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  for_each = toset(var.databases)
  name = "${var.product}-${each.key}"
}


resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "MyCatalogTable"
  database_name = "MyCatalogDatabase"
}