resource "aws_cloudwatch_log_group" "this" {
  count             = var.enabled && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name              = "${var.git}/${var.name}"
  retention_in_days = var.retention_in_days
  tags              = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [name]
  }
}
