data "template_file" "service" {
  template = coalesce(var.service_task_container_definitions, file("${path.module}/container-definitions/service.json.tpl"))

  vars = {
    name      = "${var.service_name}-${var.deployment_identifier}"
    image     = var.service_image
    command   = jsonencode(var.service_command)
    port      = var.service_port
    region    = var.region
    env_variables = jsonencode(var.env_variables)
    log_group = var.include_log_group == "yes" ? aws_cloudwatch_log_group.service[0].name : ""
  }
}

resource "aws_ecs_task_definition" "td1" {
  family                = "${var.service_name}-${var.deployment_identifier}-task"
  container_definitions = data.template_file.service.rendered

  network_mode              = var.service_task_network_mode
#  pid_mode                  = var.service_task_pid_mode
  requires_compatibilities  = ["FARGATE"]
  cpu                       = var.task_cpu
  memory                    = var.task_memory
  task_role_arn             = var.task_exec_role
  execution_role_arn        = var.task_exec_role

  runtime_platform {
    operating_system_family = "LINUX"
  }

/*   dynamic "volume" {
    for_each = var.service_volumes
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)
    }
  } */

  tags = var.tags
}
