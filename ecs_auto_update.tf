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
    "Comment" : "State machine to update ECS service on new ECR image push and simulate failure",
    "StartAt" : "SimulateFailure",
    "States" : {
      "SimulateFailure" : {
        "Type" : "Pass",
        "Result" : {
          "Services": [
            {
              "deployments": [
                {
                  "status": "FAILED"
                }
              ]
            }
          ]
        },
        "ResultPath": "$",
        "Next": "EvaluateServiceStatus"
      },
      "EvaluateServiceStatus" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.Services[0].deployments[0].status",
            "StringEquals" : "PRIMARY",
            "Next" : "SendSuccessNotification"
          },
          {
            "Variable" : "$.Services[0].deployments[0].status",
            "StringEquals" : "FAILED",
            "Next" : "SendFailureNotification"
          }
        ],
        "Default" : "CheckRetryCount"
      },
      "SendSuccessNotification" : {
        "Type" : "Task",
        "Resource" : "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters" : {
          "status": "SUCCESS",
          "service-name" : aws_ecs_service.this[0].name,
          "cluster-name" : var.cluster
        },
        "End" : true
      },
      "SendFailureNotification" : {
        "Type" : "Task",
        "Resource" : "arn:aws:lambda:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:function:${var.ecs_slack_notification_lambda}",
        "Parameters" : {
          "status": "FAILED",
          "service-name" : aws_ecs_service.this[0].name,
          "cluster-name" : var.cluster,
          "image-digest" : "sha256:1234543509248503",
          "image-tag" : "develop-latest",
          "repository-name" : "terraform-testing"
        },
        "End" : true
      },
      "CheckRetryCount" : {
        "Type" : "Pass",
        "Result" : "Unknown status or no matching state.",
        "End" : true
      }
    }
  })

  role_arn = aws_iam_role.step_functions_role[0].arn
}
