variable "ecr_name"{
  type        = string
  description = "Name for the ECR"
  default     = ""
}
variable "scan_on_push"{
  type        = bool
  description = ""
  default     = "false"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}