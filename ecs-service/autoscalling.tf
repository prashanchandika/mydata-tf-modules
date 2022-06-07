#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "${var.service_name}-${var.deployment_identifier}-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target, aws_ecs_service.service1]
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${var.service_name}-${var.deployment_identifier}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 20
      scaling_adjustment          = 1
    }

    step_adjustment {
      metric_interval_lower_bound = 20
      metric_interval_upper_bound = 40
      scaling_adjustment          = 2
    }

    step_adjustment {
      metric_interval_lower_bound = 40
      scaling_adjustment          = 4
    }
  }
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "${var.service_name}-${var.deployment_identifier}-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target, aws_ecs_service.service1]
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${var.service_name}-${var.deployment_identifier}"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }

}

# Memory Scalling Plan -------------------------------
resource "aws_appautoscaling_policy" "ecs_memory_scalling" {
  name               = "${var.service_name}-${var.deployment_identifier}-memory-scaling-policy"
  depends_on         = [aws_appautoscaling_target.scale_target, aws_ecs_service.service1]
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${var.ecs_cluster_id}/${var.service_name}-${var.deployment_identifier}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.memory_scale_target_value
  }
  
}


# -------------------------------

#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${var.service_name}-${var.deployment_identifier}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.scale_target_min_capacity
  max_capacity       = var.scale_target_max_capacity

  depends_on    = [aws_ecs_service.service1]
}