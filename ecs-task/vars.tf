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

variable "sub_product" {
  description = "The name of the sub part of the product eg: normalized"
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

variable "scan_on_push"{
  type        = bool
  description = ""
  default     = false
}

variable "task_name" {
  description = "The name of the service being created."
  type        = string
}

variable "task_count" {
  default     = 1
} 

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

# ------------------------------------------------
# Cloudwatch & Autoscalkling related Variables   -
#-------------------------------------------------
variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "85"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "10"
  type        = string
}

variable "log_group_retention" {
  description = "The number of days you want to retain log events. See cloudwatch_log_group for possible values. Defaults to 0 (forever)."
  type        = number
  default     = 0
}

variable "include_log_group" {
  description = "Whether or not to create a log group for the service (\"yes\" or \"no\"). Defaults to \"yes\"."
  type        = string
  default     = "yes"
}

variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "1"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "1"
  type        = string
}

variable "max_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "60"
  type        = string
}
variable "min_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
  default     = "60"
  type        = string
}

variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 5
  type        = number
}

variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 1
  type        = number
}

variable "memory_scale_target_value" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "40"
  type        = string
}

variable "acc_id" {
  description = " AWS AccountID"
  default     = ""
  type        = string
}

variable "secrets" {
  default = []
} 

variable "env_variables"{
  default = []
  sensitive = false

}

variable "task_port" {
  default = 80
}

variable "task_command" {
  description = "The command to run to start the container."
  type        = list(string)
  default     = []
}

variable "task_image" {
  description = "The docker image (including version) to deploy."
  default     = "latest"
  type        = string
}

variable "task_memory"{
  default = 2048
}

variable "task_cpu"{
  default = 1024
}

variable "service_task_network_mode" {
  description = "The network mode used for the containers in the task."
  default     = "awsvpc"
  type        = string
}

variable "service_task_container_definitions" {
  description = "A template for the container definitions in the task."
  default     = ""
  type        = string
}
