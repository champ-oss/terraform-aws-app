resource "aws_sfn_state_machine" "this" {
  count = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name  = substr("${var.git}-${var.name}", 0, 80)
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

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name_prefix = "${var.git}-${var.name}-role"

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
  count      = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name       = substr("${var.git}-${var.name}-ecs-update-policy", 0, 64)
  roles      = [aws_iam_role.step_functions_role[0].name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# EventBridge Rule for ECR Image Push
resource "aws_cloudwatch_event_rule" "this" {
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name_prefix = "${var.git}-${var.name}-ecr-image-push-rule"
  description = "Triggers Step Functions when an image with 'latest' tag is pushed to ECR"
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

# EventBridge Target to trigger Step Functions
resource "aws_cloudwatch_event_target" "step_function_target" {
  count    = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  rule     = aws_cloudwatch_event_rule.this[0].name
  arn      = aws_sfn_state_machine.this[0].arn
  role_arn = aws_iam_role.eventbridge_role[0].arn
}

# IAM Role for EventBridge to invoke Step Functions
resource "aws_iam_role" "eventbridge_role" {
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name_prefix = "${var.git}-${var.name}-eventbridge-role"

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
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
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
  count      = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name       = substr("${var.git}-${var.name}-invoke-step-functions-attachment", 0, 64)
  roles      = [aws_iam_role.eventbridge_role[0].name]
  policy_arn = aws_iam_policy.invoke_step_functions_policy[0].arn
}
