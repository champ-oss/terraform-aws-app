resource "aws_cloudwatch_event_rule" "trigger_step_function" {
  count          = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name_prefix    = var.git
  description    = "Rule to trigger Step Function"
  event_bus_name = "default"
  tags           = merge(local.tags, var.tags)
  event_pattern = jsonencode({
    source      = ["aws.ecr"],
    detail-type = ["ECR Image Action"],
    detail = {
      "action-type" : ["PUSH"],
      "repository-name" = [join("/", slice(split("/", split(":", var.image)[0]), 1, length(split("/", split(":", var.image)[0]))))]
      "image-tag"       = [split(":", split("/", var.image)[1])[1]],
    }
  })
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  count          = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  rule           = aws_cloudwatch_event_rule.trigger_step_function[0].name
  arn            = aws_sfn_state_machine.this[0].arn
  role_arn       = aws_iam_role.eventbridge_role[0].arn
  event_bus_name = "default"
  input_path     = "$.detail"
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
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
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
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

# IAM Role for EventBridge to invoke Step Functions
resource "aws_iam_role" "eventbridge_role" {
  count       = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name_prefix = substr("${var.git}-${var.name}-eventbridge-role", 0, 38)
  tags        = merge(local.tags, var.tags)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com",
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
      },
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = "*"
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

resource "aws_sfn_state_machine" "this" {
  count = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  name  = substr("${var.git}-${var.name}", 0, 64)
  tags  = merge(local.tags, var.tags)
  definition = jsonencode({
    "Comment": "State machine to update ECS service on new ECR image push",
    "StartAt": "UpdateECSService",
    "States": {
      "UpdateECSService": {
        "Type": "Task",
        "Resource": "arn:aws:states:::aws-sdk:ecs:updateService",
        "Parameters": {
          "Cluster": var.cluster,
          "Service": aws_ecs_service.this[0].name,
          "ForceNewDeployment": true
        },
        "Retry": [
          {
            "ErrorEquals": ["ECS.ServiceUpdateException"],
            "IntervalSeconds": 5,
            "MaxAttempts": 3,
            "BackoffRate": 2.0
          }
        ],
        "Next": "InitializeRetry"
      },
      "InitializeRetry": {
        "Type": "Pass",
        "Result": { "retryCount": 0 },
        "ResultPath": "$.retryCount",
        "Next": "WaitForServiceStabilization"
      },
      "WaitForServiceStabilization": {
        "Type": "Wait",
        "Seconds": 30,
        "Next": "CheckServiceStatus"
      },
      "CheckServiceStatus": {
        "Type": "Task",
        "Resource": "arn:aws:states:::aws-sdk:ecs:describeServices",
        "Parameters": {
          "Cluster": var.cluster,
          "Services": [aws_ecs_service.this[0].name,]
        },
        "Next": "LogServiceResponse"
      },
      "LogServiceResponse": {
        "Type": "Pass",
        "ResultPath": "$.ecsResponse",
        "Next": "FindPrimaryDeployment"
      },
      "FindPrimaryDeployment": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.ecsResponse.Services[0].Deployments[0].Status",
            "StringEquals": "PRIMARY",
            "Next": "EvaluatePrimaryRolloutState"
          },
          {
            "Variable": "$.ecsResponse.Services[0].Deployments[0].Status",
            "StringEquals": "FAILED",
            "Next": "SendFailureNotification"
          }
        ],
        "Default": "CheckRetryCount"
      },
      "EvaluatePrimaryRolloutState": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.ecsResponse.Services[0].Deployments[0].RolloutState",
            "StringEquals": "COMPLETED",
            "Next": "SendSuccessNotification"
          },
          {
            "Variable": "$.ecsResponse.Services[0].Deployments[0].RolloutState",
            "StringEquals": "FAILED",
            "Next": "SendFailureNotification"
          }
        ],
        "Default": "CheckRetryCount"
      },
      "CheckRetryCount": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.retryCount.retryCount",
            "NumericGreaterThanEquals": 20,
            "Next": "SendFailureNotification"
          }
        ],
        "Default": "IncrementRetryCount"
      },
      "IncrementRetryCount": {
        "Type": "Pass",
        "ResultPath": "$.retryCount",
        "Parameters": {
          "retryCount.$": "States.MathAdd($.retryCount.retryCount, 1)"
        },
        "Next": "WaitForServiceStabilization"
      },
      "SendSuccessNotification": {
        "Type": "Task",
        "Resource": "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters": {
          "status": "SUCCESS",
          "repository-name.$": "$$.Execution.Input.repository-name",
          "image-tag.$": "$$.Execution.Input.image-tag",
          "service-name": aws_ecs_service.this[0].name,
          "cluster-name": var.cluster,
          "image-digest.$": "$$.Execution.Input.image-digest"
        },
        "End": true
      },
      "SendFailureNotification": {
        "Type": "Task",
        "Resource": "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters": {
          "status": "FAILED",
          "repository-name.$": "$$.Execution.Input.repository-name",
          "image-tag.$": "$$.Execution.Input.image-tag",
          "service-name": aws_ecs_service.this[0].name,
          "cluster-name": var.cluster,
          "image-digest.$": "$$.Execution.Input.image-digest"
        },
        "End": true
      }
    }
  })
  role_arn = aws_iam_role.step_functions_role[0].arn
}
