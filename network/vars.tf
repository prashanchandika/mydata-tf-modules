variable "region" {
  description = "The region to create infra on"
  type        = string
}
variable "vpc_cidr" {}
variable "private_cidrs"{}
variable "public_cidrs" {}

variable "enable_nat_gateway" {
    default = false
}

variable "single_nat_gateway" {
    default = true
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "product" {
  description = "The name of the produce eg: myp2."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}