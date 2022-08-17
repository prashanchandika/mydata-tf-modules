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


#EC2
variable "sftp_instance_type" {
  type        = string
  description = "EC2 instance type for Linux Server"
  default     = "t3.micro"
}
variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}
variable "volume_size" {
  type        = number
  description = "Volumen size of root volumen of Linux Server"
  default = 10
}

variable "key_name" {
  default = "mydata-sftp"
}

#SG
variable "sftp_ingress_cidrs" {
    default = ["0.0.0.0/0"]
}



#SFTP
variable "sftp_home"{
  type    = string
  default = "/sftp_home"
}

variable "sftp_root_broadvine_dir"{
  type    = string
  default = "highgate-broadvine"
}
variable "sftp_root_mdo_dir"{
  type    = string
  default = "m3as-mdo"
}

variable "sftp_user"{
  type    = string
  default = "broadvine-sftp"
}

variable "sftp_pass"{
  type    = string
  default = "broadvine-sftp"
  sensitive   = true
}

variable "mdo_pass"{
  type = string
  default = "mdo@123"
  sensitive   = true
}

variable "mdo_user"{
  type = string
  default = "mdo"
}



#tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}