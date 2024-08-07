locals {
  route53_health_check_resource_path = (
    var.enable_public_healthcheck_rule ?
    try("${aws_lb_target_group.this[0].health_check[0].path}?${var.healthcheck_query_parameter}=${random_password.healthcheck[0].result}", "") :
    try(aws_lb_target_group.this[0].health_check[0].path, "")
  )
  autoscaling_min_capacity = try(aws_appautoscaling_target.this[0].min_capacity, 0)
}

resource "aws_route53_health_check" "this" {
  count             = var.enabled && var.enable_route53_health_check && local.autoscaling_min_capacity != 0 ? 1 : 0
  fqdn              = try(aws_route53_record.this[0].name, "fallback")
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = try(local.route53_health_check_resource_path, "")
  failure_threshold = 3
  request_interval  = 30
  regions           = ["us-east-1", "us-west-1", "us-west-2"]
  tags              = merge(local.tags, var.tags, local.name_tag)
  measure_latency   = true
}
