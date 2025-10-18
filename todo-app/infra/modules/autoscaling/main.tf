locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_appautoscaling_target" "api" {
  min_capacity = 1
  max_capacity = 2

  resource_id = "service/${var.autoscaling_settings.cluster_name}/${var.autoscaling_settings.service_name}"

  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

  tags = {
    Name = "${local.prefix}-ecs-api-autoscaling-target"
  }
}

resource "aws_appautoscaling_policy" "api_cpu_target" {
  name = "${local.prefix}-api-cpu-target"

  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    # 検証のためCPU使用率30%を指定
    target_value       = 30
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

}
