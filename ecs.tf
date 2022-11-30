locals {
  # Create a map of environment variable name to SSM parameter name to pass into container definition.
  # Example: { MY_ENV_VAR1 = "ssm_parameter_name1", MY_ENV_VAR2 = "ssm_parameter_name2" }
  kms_ssm = { for ssm in aws_ssm_parameter.this : trimprefix(ssm.name, local.ssm_prefix) => ssm.name }

  # Create a env variable whose value will change any time a KMS value is changed. This is a way of forcing ECS
  # service to cycle any time KMS values are updated.
  kms_secrets_sha = { KMS_SECRETS_SHA = sha256(jsonencode(var.kms_secrets)) }

  container = [
    {
      name        = "this"
      image       = var.image
      essential   = true
      environment = [for key, value in merge(var.environment, local.kms_secrets_sha) : { name = key, value = value }]
      secrets     = [for key, value in merge(var.secrets, local.kms_ssm) : { name = key, valueFrom = value }]
      command     = var.command != [] ? var.command : null
      portMappings = [
        {
          containerPort = var.port
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.git}-${var.name}"
  container_definitions    = jsonencode(local.container)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = merge(local.tags, var.tags)
}

resource "aws_ecs_service" "this" {
  count                              = var.enable_load_balancer ? 1 : 0
  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = aws_ecs_task_definition.this.arn
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  depends_on                         = [aws_lb_listener_rule.this]
  wait_for_steady_state              = var.wait_for_steady_state
  tags                               = merge(local.tags, var.tags)
  enable_execute_command             = var.enable_execute_command
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.this.id
    container_name   = local.container[0].name
    container_port   = var.port
  }

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.subnets
  }

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker_enable
    rollback = var.deployment_circuit_breaker_rollback
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "disabled_load_balancer" {
  count                              = var.enable_load_balancer ? 0 : 1
  name                               = var.name
  cluster                            = var.cluster
  task_definition                    = aws_ecs_task_definition.this.arn
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"
  wait_for_steady_state              = var.wait_for_steady_state
  tags                               = merge(local.tags, var.tags)
  enable_execute_command             = var.enable_execute_command
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.subnets
  }

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker_enable
    rollback = var.deployment_circuit_breaker_rollback
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}