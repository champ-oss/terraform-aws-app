resource "aws_appautoscaling_target" "this" {
  depends_on         = [aws_ecs_service.this, aws_ecs_service.disabled_load_balancer]
  max_capacity       = var.desired_count != null ? var.desired_count : var.max_capacity
  min_capacity       = var.desired_count != null ? var.desired_count : var.min_capacity
  resource_id        = "service/${var.cluster}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  depends_on         = [aws_ecs_service.this, aws_ecs_service.disabled_load_balancer]
  name               = "${var.git}-${var.name}"
  policy_type        = var.autoscaling_policy_type
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_predefined_metric_type
    }

    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "request_count_per_target" {
  count              = var.enable_ecs_request_count_target_autoscale ? 1 : 0
  name               = "${var.git}-${var.name}-request-count-per-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.load_balancer_arn_suffix}/${aws_lb_target_group.this.arn_suffix}"
    }

    target_value       = var.ecs_request_count_autoscale_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}
