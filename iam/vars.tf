variable "region" {
  description = "The region to create infra on"
  type        = string
}
variable "backend_region" {
  description = "The region to refer for backend data"
  type        = string
}

variable "project" {
  description = "project name. just for tfstate paths"
  type        = string
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
