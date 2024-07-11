moved {
  from = aws_appautoscaling_target.this
  to   = aws_appautoscaling_target.this[0]
}

moved {
  from = aws_appautoscaling_policy.this
  to   = aws_appautoscaling_policy.this[0]
}

moved {
  from = aws_cloudwatch_log_group.this
  to   = aws_cloudwatch_log_group.this[0]
}

moved {
  from = aws_ecs_task_definition.this
  to   = aws_ecs_task_definition.this[0]
}

moved {
  from = aws_ecs_service.this
  to   = aws_ecs_service.this[0]
}

moved {
  from = aws_ecs_service.disabled_load_balancer
  to   = aws_ecs_service.disabled_load_balancer[0]
}

moved {
  from = data.aws_region.this
  to   = data.aws_region.this[0]
}


moved {
  from = module.route53_health_check[0].aws_route53_health_check.this
  to   = aws_route53_health_check.this[0]
}