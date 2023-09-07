resource "aws_lb_target_group" "this" {
  port                 = var.port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  tags                 = merge(local.tags, var.tags)
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.healthcheck
    matcher             = var.matcher
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
    timeout             = var.timeout
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

locals {
  rules_needed = length(var.source_ips) > 5 ? ceil(length(var.source_ips) / 5) : 1
}

resource "aws_lb_listener_rule" "this" {
  count        = var.enable_load_balancer ? local.rules_needed : 0
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
        values = slice(
          var.source_ips,
          count.index * 5,
          ((count.index * 5) + 5) > length(var.source_ips) ? length(var.source_ips) : (count.index * 5) + 5
        )
      }
    }
  }
}

resource "aws_lb_listener_rule" "public_healthcheck" {
  count        = var.enable_load_balancer && var.enable_public_healthcheck_rule ? 1 : 0
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

  condition {
    path_pattern {
      values = [var.healthcheck]
    }
  }

  condition {
    query_string {
      key   = var.healthcheck_query_parameter
      value = random_password.healthcheck[0].result
    }
  }
}

