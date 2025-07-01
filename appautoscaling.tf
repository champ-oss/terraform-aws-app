resource "aws_appautoscaling_target" "this" {
  count              = var.enabled ? 1 : 0
  depends_on         = [aws_ecs_service.this, aws_ecs_service.disabled_load_balancer]
  max_capacity       = var.desired_count != null ? var.desired_count : var.max_capacity
  min_capacity       = var.desired_count != null ? var.desired_count : var.min_capacity
  resource_id        = "service/${var.cluster}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      tags     # https://github.com/hashicorp/terraform-provider-aws/issues/31261#issuecomment-2333629562
      tags_all # https://github.com/hashicorp/terraform-provider-aws/issues/31261#issuecomment-2333629562
    ]
  }
}

resource "aws_appautoscaling_policy" "this" {
  count              = var.enabled ? 1 : 0
  depends_on         = [aws_ecs_service.this, aws_ecs_service.disabled_load_balancer]
  name               = "${var.git}-${var.name}"
  policy_type        = var.autoscaling_policy_type
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_predefined_metric_type
      resource_label         = var.autoscaling_predefined_metric_type == "ALBRequestCountPerTarget" ? "${var.alb_arn_suffix}/${aws_lb_target_group.this[0].arn_suffix}" : null
    }

    target_value       = var.autoscaling_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

