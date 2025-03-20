resource "aws_cloudwatch_event_bus" "cross_account_bus" {
  count = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name  = substr(var.git, 0, 64)
  tags  = merge(local.tags, var.tags)
}

data "aws_iam_policy_document" "cross_account_event_policy" {
  count = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  statement {
    sid    = "ecraccountaccess"
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      "arn:aws:events:${data.aws_region.this[0].name}:${var.source_ecr_account}event-bus/default"
    ]

    principals {
      type        = "AWS"
      identifiers = [var.source_ecr_account]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "cross_account_event_policy" {
  count = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  policy         = data.aws_iam_policy_document.cross_account_event_policy[0].json
  event_bus_name = aws_cloudwatch_event_bus.cross_account_bus[0].name
}

resource "aws_cloudwatch_event_rule" "trigger_step_function" {
  count          = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name           = "trigger-step-function"
  event_bus_name = aws_cloudwatch_event_bus.cross_account_bus[0].name
  tags           = merge(local.tags, var.tags)
  event_pattern = jsonencode({
    source      = ["aws.ecr"],
    detail-type = ["ECR Image Action"],
    detail = {
      "action-type" : ["PUSH"],
      "repository-name" = [var.ecr_repository_name],
      "image-tag"       = [var.ecr_image_tag]
    }
  })
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  count    = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  rule     = aws_cloudwatch_event_rule.trigger_step_function[0].name
  arn      = aws_sfn_state_machine.this[0].arn
  role_arn = aws_iam_role.eventbridge_role[0].arn
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  count       = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name_prefix = var.git
  tags        = merge(local.tags, var.tags)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a policy for ECS update permissions
resource "aws_iam_policy_attachment" "ecs_update_policy" {
  count      = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name       = substr("${var.git}-${var.name}-ecs-update-policy", 0, 64)
  roles      = [aws_iam_role.step_functions_role[0].name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# IAM Role for EventBridge to invoke Step Functions
resource "aws_iam_role" "eventbridge_role" {
  count       = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name_prefix = substr("${var.git}-${var.name}-eventbridge-role", 0, 38)
  tags        = merge(local.tags, var.tags)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy for EventBridge to invoke Step Functions
resource "aws_iam_policy" "invoke_step_functions_policy" {
  count       = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name_prefix = "${var.git}-${var.name}-invoke-step-functions-policy"
  description = "Policy to allow EventBridge to invoke Step Functions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = aws_sfn_state_machine.this[0].arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "invoke_step_functions_attachment" {
  count      = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name       = substr("${var.git}-${var.name}-invoke-step-functions-attachment", 0, 64)
  roles      = [aws_iam_role.eventbridge_role[0].name]
  policy_arn = aws_iam_policy.invoke_step_functions_policy[0].arn
}

resource "aws_sfn_state_machine" "this" {
  count = var.enabled && var.enable_ecs_auto_update && !var.enable_source_ecr_event_bridge_rule ? 1 : 0
  name  = substr("${var.git}-${var.name}", 0, 64)
  tags  = merge(local.tags, var.tags)
  definition = jsonencode({
    "Comment" : "State machine to update ECS service on new ECR image push",
    "StartAt" : "UpdateECSService",
    "States" : {
      "UpdateECSService" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::aws-sdk:ecs:updateService",
        "Parameters" : {
          "Cluster" : var.cluster,
          "Service" : aws_ecs_service.this[0].name,
          "ForceNewDeployment" : true
        },
        "Retry" : [
          {
            "ErrorEquals" : ["ECS.ServiceUpdateException"],
            "IntervalSeconds" : 5,
            "MaxAttempts" : 3,
            "BackoffRate" : 2.0
          }
        ],
        "End" : true
      }
    }
  })
  role_arn = aws_iam_role.step_functions_role[0].arn
}


