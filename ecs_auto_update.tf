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


resource "aws_iam_role_policy_attachment" "ecs_update_policy" {
  count      = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  role       = aws_iam_role.step_functions_role[0].name
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

resource "aws_iam_role_policy_attachment" "invoke_step_functions_attachment" {
  count      = var.enabled && var.enable_ecs_auto_update ? 1 : 0
  role       = aws_iam_role.eventbridge_role[0].name
  policy_arn = aws_iam_policy.invoke_step_functions_policy[0].arn
}

resource "aws_sfn_state_machine" "this" {
  count = var.enabled && var.enable_ecs_auto_update ? 1 : 0
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
          "Service" : try(aws_ecs_service.this[0].name, ""),
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
        "Next" : "WaitForServiceStabilization"
      },
      "WaitForServiceStabilization" : {
        "Type" : "Wait",
        "Seconds" : 30,
        "Next" : "CheckIfFirstRetry"
      },
      "CheckIfFirstRetry" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.RetryData.retryCount",
            "IsPresent" : true,
            "Next" : "CheckServiceStatus"
          }
        ],
        "Default" : "InitializeRetry"
      },
      "InitializeRetry" : {
        "Type" : "Pass",
        "Result" : { "RetryData" : { "retryCount" : 0 } },
        "ResultPath" : "$",
        "Next" : "CheckServiceStatus"
      },
      "CheckServiceStatus" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::aws-sdk:ecs:describeServices",
        "Parameters" : {
          "Cluster" : var.cluster,
          "Services" : [try(aws_ecs_service.this[0].name, "")]
        },
        "ResultPath" : "$.ecsResponse",
        "Next" : "MergeRetryData"
      },
      "MergeRetryData" : {
        "Type" : "Pass",
        "Parameters" : {
          "RetryData.$" : "$.RetryData",
          "ecsResponse.$" : "$.ecsResponse"
        },
        "ResultPath" : "$",
        "Next" : "EvaluateServiceStatus"
      },
      "EvaluateServiceStatus" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "And" : [
              {
                "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                "StringEquals" : "PRIMARY"
              },
              {
                "Variable" : "$.ecsResponse.Services[0].Deployments[0].RunningCount",
                "NumericGreaterThanEquals" : 1
              }
            ],
            "Next" : "SendSuccessNotification"
          },
          {
            "And" : [
              {
                "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                "StringEquals" : "PRIMARY"
              },
              {
                "Or" : [
                  {
                    "Variable" : "$.ecsResponse.Services[0].Deployments[0].FailedTasks",
                    "NumericGreaterThanEquals" : 1
                  },
                  {
                    "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                    "StringEquals" : "ROLLBACK_IN_PROGRESS"
                  },
                  {
                    "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                    "StringEquals" : "STOPPED"
                  },
                  {
                    "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                    "StringEquals" : "ROLLBACK_FAILED"
                  },
                  {
                    "Variable" : "$.ecsResponse.Services[0].Deployments[0].Status",
                    "StringEquals" : "ROLLBACK_COMPLETED"
                  }
                ]
              }
            ],
            "Next" : "SendFailureNotification"
          }
        ],
        "Default" : "CheckRetryCount"
      },
      "CheckRetryCount" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.RetryData.retryCount",
            "NumericGreaterThanEquals" : 20,
            "Next" : "SendFailureNotification"
          }
        ],
        "Default" : "IncrementRetryCount"
      },
      "IncrementRetryCount" : {
        "Type" : "Pass",
        "Parameters" : {
          "RetryData" : {
            "retryCount.$" : "States.MathAdd($.RetryData.retryCount, 1)"
          },
          "ecsResponse.$" : "$.ecsResponse"
        },
        "ResultPath" : "$",
        "Next" : "WaitForServiceStabilization"
      },
      "SendSuccessNotification" : {
        "Type" : "Task",
        "Resource" : "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters" : {
          "status" : "SUCCESS",
          "repository-name.$" : "$$.Execution.Input.repository-name",
          "image-tag.$" : "$$.Execution.Input.image-tag",
          "service-name" : try(aws_ecs_service.this[0].name, ""),
          "cluster-name" : var.cluster,
          "ecs-slack-channel" : var.ecs_slack_channel,
          "image-digest.$" : "$$.Execution.Input.image-digest"
        },
        "End" : true
      },
      "SendFailureNotification" : {
        "Type" : "Task",
        "Resource" : "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters" : {
          "status" : "FAILED",
          "repository-name.$" : "$$.Execution.Input.repository-name",
          "image-tag.$" : "$$.Execution.Input.image-tag",
          "service-name" : try(aws_ecs_service.this[0].name, ""),
          "cluster-name" : var.cluster,
          "ecs-slack-channel" : var.ecs_slack_channel,
          "image-digest.$" : "$$.Execution.Input.image-digest"
        },
        "End" : true
      }
    }
  })
  role_arn = aws_iam_role.step_functions_role[0].arn
}