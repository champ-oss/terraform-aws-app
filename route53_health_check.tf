resource "aws_route53_health_check" "this" {
  count             = var.enabled && var.enable_route53_health_check ? 1 : 0
  fqdn              = try(aws_route53_record.this[0].name, "fallback")
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = try("${aws_lb_target_group.this[0].health_check[0].path}?${var.healthcheck_query_parameter}=${random_password.healthcheck[0].result}", "")
  failure_threshold = 3
  request_interval  = 30
  regions           = ["us-east-1", "us-west-1", "us-west-2"]
  tags              = merge(local.tags, var.tags, local.name_tag)
  measure_latency   = true
}
