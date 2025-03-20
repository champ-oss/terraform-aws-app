# add ecr repository creation at some point

# event bridge rule to trigger ecs auto update from source account to target account
resource "aws_cloudwatch_event_rule" "ecr_image_push_rule" {
  count       = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  name_prefix = var.git
  description = "Rule to trigger ECS Auto Update"
  event_pattern = jsonencode({
    source      = ["aws.ecr"],
    detail-type = ["ECR Image Action"],
    detail = {
      "action-type"     = ["PUSH"],
      "repository-name" = [var.ecr_repository_name],
      "image-tag"       = [var.ecr_image_tag]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_target_account" {
  count    = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  rule     = aws_cloudwatch_event_rule.ecr_image_push_rule[0].name
  arn      = aws_cloudwatch_event_bus.cross_account_bus[0].arn
  role_arn = aws_iam_role.cross_account_event_role[0].arn
}

data "aws_iam_policy_document" "sts_event_policy" {
  count = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "cross_account_event_policy" {
  count = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  statement {
    actions = [
      "events:PutEvents"
    ]
    resources = [aws_cloudwatch_event_bus.cross_account_bus[0].arn]
  }
}

# create a role to allow source account to send events to target account
resource "aws_iam_role" "cross_account_event_role" {
  count              = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  name_prefix        = "${var.git}-${var.name}-cross-account-event-role"
  assume_role_policy = data.aws_iam_policy_document.sts_event_policy[0].json
}

resource "aws_iam_role_policy" "cross_account_event_policy" {
  count  = var.enabled && var.enable_source_ecr_event_bridge_rule && var.enable_ecs_auto_update ? 1 : 0
  name   = "${var.git}-${var.name}-cross-account-event-policy"
  role   = aws_iam_role.cross_account_event_role[0].name
  policy = data.aws_iam_policy_document.cross_account_event_policy[0].json
}
