resource "aws_cloudwatch_metric_alarm" "cpu_avg_utilization" {
  count = var.enabled && var.metric_alarms_enabled ? 1 : 0

  alarm_name          = "/${var.cluster}/${var.name}/cpu-avg-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_avg_utilization_threshold
  alarm_description   = "This metric monitors CPU utilization"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  tags                = merge(local.tags, var.tags)
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_avg_utilization" {
  count = var.enabled && var.metric_alarms_enabled ? 1 : 0

  alarm_name          = "/${var.cluster}/${var.name}/memory-avg-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_avg_utilization_threshold
  alarm_description   = "This metric monitors memory utilization"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  tags                = merge(local.tags, var.tags)
  dimensions = {
    ClusterName = var.cluster
    ServiceName = var.name
  }
}
