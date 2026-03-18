resource "aws_cloudwatch_event_rule" "ecs_deployment" {
  count          = var.enabled && !var.paused && var.enable_ecs_observability ? 1 : 0
  name_prefix    = "${var.git}-ecs"
  description    = "Send ECS deployments (COMPLETED or FAILED) to central observability bus"
  event_bus_name = "default"
  tags           = merge(local.tags, var.tags)

  event_pattern = jsonencode({
    source        = ["aws.ecs"],
    "detail-type" = ["ECS Deployment State Change"],
    detail = {
      rolloutState = ["COMPLETED", "FAILED"]
      serviceName = [var.enable_load_balancer ? try(aws_ecs_service.this[0].name, "") : try(aws_ecs_service.disabled_load_balancer[0].name, "")]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_central_bus" {
  count      = var.enabled && !var.paused && var.enable_ecs_observability ? 1 : 0
  rule       = aws_cloudwatch_event_rule.ecs_deployment[0].name
  arn        = var.central_bus  # central bus ARN
  role_arn   = aws_iam_role.eventbridge_cross_account[0].arn
}

resource "aws_iam_role" "eventbridge_cross_account" {
  count       = var.enabled && !var.paused && var.enable_ecs_observability ? 1 : 0
  name_prefix = substr("${var.git}-eventbridge-cross-account", 0, 38)
  tags        = merge(local.tags, var.tags)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "put_events_to_central" {
  count       = var.enabled && !var.paused && var.enable_ecs_observability ? 1 : 0
  name_prefix = "${var.git}-put-events-to-central"
  description = "Allow EventBridge to send ECS deployment events to central bus"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "events:PutEvents",
        Resource = var.central_bus
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_put_events_policy" {
  count      = var.enabled && !var.paused && var.enable_ecs_observability ? 1 : 0
  role       = aws_iam_role.eventbridge_cross_account[0].name
  policy_arn = aws_iam_policy.put_events_to_central[0].arn
}