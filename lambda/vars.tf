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

variable "lambda_name" {
  description = ""
  type        = string
}

variable "handler" {
  description = ""
  type        = string
  default     = "com.mydata.ingestion.handlers.S3EventHandler::handleRequest"
}

variable "runtime" {
  description = ""
  type        = string
  default     = "java8.al2"
}

variable "s3_bucket" {
  description = ""
  type        = string
  default     = "mydata-normalized-ingestion-dev"
}

variable "s3_key" {
  description = ""
  type        = string
  default     = "artifacts/mydata-ingestion-dev-e2463070-b13a-4603-a685-65232b2387b3.zip"
}



variable "lambda_trigger" {
  default = ""
}
variable "lambda_port" {
  description = ""
  type        = string
  default     = "80"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


