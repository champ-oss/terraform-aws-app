resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.git}/${var.name}"
  retention_in_days = var.retention_in_days
  tags              = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [name]
  }
}