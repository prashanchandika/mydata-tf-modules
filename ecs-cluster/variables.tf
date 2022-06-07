variable "region" {
  description = "JUst the region to work with"
  type        = string
}


variable "create_ecs" {
  description = "Controls if ECS should be created"
  type        = bool
  default     = true
}

variable "product" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
  default     = null
}

variable "sub_product" {
  description = "The name of the sub part of the product eg: normalized"
  type        = string
}

variable "deployment_identifier" {
  description = "Environment"
  type        = string
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster. Can be one or more."
  type        = list(map(any))
  default     = [
    {
      capacity_provider = "FARGATE"
    }
]
}

variable "container_insights" {
  description = "Controls if ECS Cluster has container insights enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}
