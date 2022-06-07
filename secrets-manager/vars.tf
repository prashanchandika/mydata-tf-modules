variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

# Secret 

variable "secret_name" {
    description = ""
    type        = string
}


variable "secret_string" {
  description = ""
  type        = string
}


