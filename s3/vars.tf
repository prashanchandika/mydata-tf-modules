variable "region" {
  description = "The region into which to deploy the service."
  type        = string
}

variable "backend_region" {
  description = "The region to refer for backend data"
  type        = string
}

variable "product" {
  description = "The name of the produce eg: myp2."
  type        = string
}

variable "project" {
  description = "project name. just for tfstate paths"
  type        = string
}

variable "bucket_name" {
  description = "project name. just for tfstate paths"
  type        = string
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}