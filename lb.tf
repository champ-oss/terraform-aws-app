resource "aws_lb_target_group" "this" {
  port                 = var.port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  tags                 = merge(local.tags, var.tags)
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = var.enabled_health_check
    path                = var.enabled_health_check != false ? var.healthcheck : null
    matcher             = var.enabled_health_check != false ? var.matcher : null
    healthy_threshold   = var.enabled_health_check != false ? var.healthy_threshold : null
    unhealthy_threshold = var.enabled_health_check != false ? var.unhealthy_threshold : null
    interval            = var.enabled_health_check != false ? var.interval : null
    timeout             = var.enabled_health_check != false ? var.timeout : null
  }

  dynamic "stickiness" {
    for_each = var.stickiness != null ? var.stickiness : []
    content {
      enabled         = stickiness.value.enabled
      type            = stickiness.value.type
      cookie_name     = try(stickiness.value.cookie_name, null)
      cookie_duration = stickiness.value.cookie_duration
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "this" {
  count        = var.enable_load_balancer ? 1 : 0
  depends_on   = [aws_lb_target_group.this]
  listener_arn = var.listener_arn
  tags         = merge(local.tags, var.tags)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.dns_name]
    }
  }

  dynamic "condition" {
    for_each = var.source_ips != null ? [1] : []

    content {
      source_ip {
        values = var.source_ips
      }
    }
  }
}
