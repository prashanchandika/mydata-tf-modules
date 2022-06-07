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

variable "sub_product" {
  description = "The name of the sub part of the product eg: normalized"
  type        = string
}

variable "internal" {
  description = "If the Alb is public facing or internal"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "lb_from_port" {
  description = "A map of tags to add to all resources"
  default     = "4000"
}

variable "lb_to_port" {
  description = "A map of tags to add to all resources"
  default     = "5999"
}
