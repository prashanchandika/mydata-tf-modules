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

# ECS #############################################
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "service_task_container_definitions" {
  description = "A template for the container definitions in the task."
  default     = ""
  type        = string
}
variable "service_task_network_mode" {
  description = "The network mode used for the containers in the task."
  default     = ""
  type        = string
}
variable "service_task_pid_mode" {
  description = "The process namespace used for the containers in the task."
  default     = null
  type        = string
}

variable "service_name" {
  description = "The name of the service being created."
  type        = string
}

variable "service_name_short" {
  description = "The short name of the service being create the Target group."
  type        = string
}

variable "rds_name" {
  description = "The name of the service being created."
  type        = string
  default     = "test"
}


variable "service_image" {
  description = "The docker image (including version) to deploy."
  default     = ""
  type        = string
}
variable "service_image_repo" {
  description = "The docker image (including version) to deploy."
  default     = ""
  type        = string
}
variable "service_image_tag" {
  description = "The docker image (including version) to deploy."
  default     = ""
  type        = string
}
variable "service_command" {
  description = "The command to run to start the container."
  type        = list(string)
  default     = []
}
variable "service_port" {
  description = "The port the containers will be listening on."
  type        = string
  default     = ""
}

variable "listener_port" {
  description = ""
  type        = string
  default     = ""
}

variable "certificate_arn" {
  type = string
  default = ""
}

variable "service_deployment_maximum_percent" {
  description = "The maximum percentage of the desired count that can be running."
  type        = number
  default     = 200
}
variable "service_deployment_minimum_healthy_percent" {
  description = "The minimum healthy percentage of the desired count to keep running."
  type        = number
  default     = 200
}
variable "service_health_check_grace_period_seconds" {
  description = "The number of seconds to wait for the service to start up before starting load balancer health checks."
  type        = number
  default     = 0
}

variable "task_memory"{
  default = 2048
}
variable "task_cpu"{
  default = 1024
}

variable "attach_to_load_balancer" {
  description = "Whether or not this service should attach to a load balancer (\"yes\" or \"no\")."
  type        = string
  default     = "yes"
}
variable "service_elb_name" {
  description = "The name of the ELB to configure to point at the service containers."
  type        = string
  default     = ""
}
variable "target_group_arn" {
  description = "The arn of the target group to point at the service containers."
  type        = string
  default     = ""
}
variable "target_container_name" {
  description = "The name of the container to which the load balancer should route traffic. Defaults to the service_name."
  type        = string
  default     = ""
}
variable "tg_port" {
  description = "The port to which the load balancer should route traffic. Defaults to the service_port."
  type        = string
  default     = "80"
}

variable "register_in_service_discovery" {
  description = "Whether or not this service should be registered in service discovery (\"yes\" or \"no\")."
  type        = string
  default     = "no"
}
variable "service_discovery_create_registry" {
  description = "Whether or not to create a service discovery registry for this service (\"yes\" or \"no\")."
  type        = string
  default     = "yes"
}
variable "service_discovery_namespace_id" {
  description = "The ID of the service discovery namespace in which to create the service discovery registry. Required if service_discovery_create_registry is \"yes\"."
  type        = string
  default     = ""
}
variable "service_discovery_registry_arn" {
  description = "The ARN of the service discovery registry into which to register the service. Required if service_discovery_create_registry is \"no\"."
  type        = string
  default     = ""
}
variable "service_discovery_record_type" {
  description = "The type of record to create when registering the service in service discovery."
  type        = string
  default     = "SRV"
}
variable "service_discovery_container_name" {
  description = "The container name to use when registering the service in service discovery. Defaults to the service name."
  type        = string
  default     = ""
}
variable "service_discovery_container_port" {
  description = "The container port to use when registering the service in service discovery. Defaults to the service port."
  type        = string
  default     = ""
}

variable "associate_default_security_group" {
  description = "Whether or not to create and associate a default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "include_default_ingress_rule" {
  description = "Whether or not to include the defauregionlt ingress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "include_default_egress_rule" {
  description = "Whether or not to include the default egress rule in the default security group for the tasks created by this service (\"yes\" or \"no\"). Defaults to \"yes\". Only applicable when service_task_network_mode is \"awsvpc\"."
  type        = string
  default     = "yes"
}
variable "default_security_group_ingress_cidrs" {
  description = "The CIDRs allowed access to containers when using the default security group."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
variable "default_security_group_egress_cidrs" {
  description = "The CIDRs accessible from containers when using the default security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_volumes" {
  description = "A list of volumes to make available to the containers in the service."
  type        = list(map(string))
  default     = []
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for this service (\"REPLICA\" or \"DAEMON\")."
  type        = string
  default     = "REPLICA"
}

variable "placement_constraints" {
  description = "A list of placement constraints for the service."
  type        = list(map(string))
  default     = []
}

/* variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster in which to deploy the service."
  type        = string
} */
/* variable "ecs_cluster_service_role_arn" {
  description = "The ARN of the IAM role to provide to ECS to manage the service."
  type        = string
} */

variable "include_log_group" {
  description = "Whether or not to create a log group for the service (\"yes\" or \"no\"). Defaults to \"yes\"."
  type        = string
  default     = "yes"
}

variable "log_group_retention" {
  description = "The number of days you want to retain log events. See cloudwatch_log_group for possible values. Defaults to 0 (forever)."
  type        = number
  default     = 0
}

variable "force_new_deployment" {
  description = "Whether or not to force a new deployment of the service (\"yes\" or \"no\"). Defaults to \"no\"."
  type        = string
  default     = "no"
}

variable "service_desired_count" {
  description = ""
  type        = string
  default     = "1"
}

variable "container_port" {
  description = ""
  type        = string
  default     = "3999"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}
variable "tg_name" {
  description = ""
  type        = string
  default     = ""
}

variable "ecs_cluster_id" {
  description = ""
  type        = string
  default     = ""
}
variable "service_role" {
  description = ""
  type        = string
  default     = "arn:aws:iam::936341724687:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
}
variable "internal_alb_arn" {
  description = ""
  type        = string
  default     = ""
}

variable "external_alb_arn" {
  description = ""
  type        = string
  default     = ""
}

variable "external_service" {
  description = "if the service should be attached to the internal facing alb"
  type        = bool
  default = false
}


variable "listener_protocol" {
  description = ""
  type        = string
  default     = "HTTP"
}

variable "env_variables"{
  default = [
        {
          "name": "ENV1",
          "value": "80"
        },
        {
          "name": "ENV2",
          "value": "xxxxx"
        }
      ]
  sensitive = false

}

variable "backend_hosts" {
  description = "list of backend hosts to add as env variables pointing to internal alb"
  type        = list
  default     = []
}

variable "common_envs" {
  default = []
}

variable "enable_execute_command" {
  type = bool
  default = true
}



# Autoscalling Related Variables 

variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "50"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "20"
  type        = string
}

variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "3"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "3"
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
#############################################

# RDS ######################################################
variable "create_rds" {
  default = false
}


variable "allocated_storage"{
  default = 10
}

variable "engine"{
    type = string
    default = "postgres"
}

variable "engine_version"{
    type = string
    default = "12.7"
}

variable "instance_class"{
    type = string
    default ="db.t3.micro"
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

variable "db_port" {
  type    = string
  default = "5432"
}

variable "parameter_group_name" {
  type    = string
  default = "default.postgres12"
}

# ECR #################################
variable "ecr_name"{
  type        = string
  description = "Name for the ECR"
  default     = ""
}
variable "scan_on_push"{
  type        = bool
  description = ""
  default     = false
}



variable "secrets" {
  
} 