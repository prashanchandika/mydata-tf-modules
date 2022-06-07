output "task_definition_arn" {
  description = "The ARN of the created ECS task definition."
  value       = aws_ecs_task_definition.td1.arn
}

output "log_group" {
  description = "The name of the log group capturing all task output."
  value       = var.include_log_group == "yes" ? aws_cloudwatch_log_group.service[0].name : ""
}

output "listener_port" {
  description = "The Port listener ALB listener is configured to listen on"
  value       = aws_alb_listener.lis1.*.port
}

output "listener_arn" {
  description = "ARN of the listener"
  value       = aws_alb_listener.lis1.*.arn
}

output "listener_id" {
  description = "ID of the listener"
  value       = aws_alb_listener.lis1.*.id
}

# http listener
/* output "listener_arn_http" {
  description = "ARN of the HTTP listener"
  value       = aws_alb_listener.lis_http.*.arn
}

output "listener_id_http" {
  description = "ARN of the HTTP listener"
  value       = aws_alb_listener.lis_http.*.id
} */

# https listener
/* output "listener_arn_https" {
  description = "ARN of the HTTPS listener"
  value       = aws_alb_listener.lis_https.*.arn
}

output "listener_id_https" {
  description = "ID of the HTTPS listener"
  value       = aws_alb_listener.lis_https.*.id
} */