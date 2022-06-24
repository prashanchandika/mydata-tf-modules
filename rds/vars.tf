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

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "allocated_storage"{
  default = 10

}

variable "create_rds" {
  type = bool
  default = true
}

variable "engine"{
    type = string
    default = "postgres"
}

variable "engine_family" {
  type = string
  default = "POSTGRESQL"
}

variable "engine_version"{
    type = string
    default = "12.8"
}

variable "instance_class"{
    type = string
    default ="db.t3.micro"
}

variable "rds_name"{
    type = string
    default = "testrds"
}

variable "identifier"{
    type = string
    default = "testdb"
}

variable "username"{
    type = string
    sensitive   = true
}

variable "password"{
    type = string
    sensitive   = true
}

variable "skip_final_snapshot"{
    type = bool
    default = true
}

variable "publicly_accessible"{
    type = bool
    default = false
}

variable "db_subnet_ids"{
    type    = list(string)
    default = []
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "db_port" {
  type    = string
  default = "5432"
}

variable "parameter_group_name" {
  type    = string
  default = "default.postgres12"
}
 
variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}