resource "aws_cloudwatch_log_group" "service" {
  count = var.include_log_group == "yes" ? 1 : 0

  name = "${var.deployment_identifier}/ecs-service/${var.service_name}"
  retention_in_days = var.log_group_retention

  tags = var.tags
}

# Alarms ##############################################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.max_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.max_cpu_period
  statistic           = "Maximum"
  threshold           = var.max_cpu_threshold
  dimensions = {
    ClusterName = var.ecs_cluster_id
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]

  tags = var.tags
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.service_name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.min_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.min_cpu_period
  statistic           = "Average"
  threshold           = var.min_cpu_threshold
  dimensions = {
    ClusterName = var.ecs_cluster_id
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]

  tags = var.tags
}


