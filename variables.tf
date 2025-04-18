variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "git" {
  description = "Exact name of your git repository"
  type        = string
}

variable "wait_for_steady_state" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#wait_for_steady_state"
  type        = bool
  default     = true
}

variable "port" {
  description = "Port number of the service running inside your container"
  type        = number
  default     = 8080
}

variable "cluster" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#cluster"
  type        = string
}

variable "healthcheck" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#path"
  type        = string
  default     = "/"
}

variable "health_check_grace_period_seconds" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#health_check_grace_period_seconds"
  default     = 30
  type        = number
}

variable "security_groups" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#security_groups"
  type        = list(string)
  default     = []
}

variable "execution_role_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#execution_role_arn"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#subnets"
  type        = list(string)
}

variable "listener_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#listener_arn"
  type        = string
  default     = ""
}

variable "dns_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#name"
  type        = string
  default     = ""
}

variable "enable_route53" {
  description = "Create Route 53 record"
  type        = bool
  default     = true
}

variable "enable_load_balancer" {
  description = "enable load balancer"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable_execute_command"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id"
  type        = string
  default     = ""
}

variable "lb_dns_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#dns_name"
  type        = string
  default     = ""
}

variable "lb_zone_id" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#zone_id"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#vpc_id"
  type        = string
}

variable "name" {
  description = "Unique identifier for naming resources"
  type        = string
}

variable "image" {
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_image"
  type        = string
}

variable "cpu" {
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 256
}

variable "matcher" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#matcher"
  type        = string
  default     = "200,301,302"
}

variable "memory" {
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  type        = number
  default     = null
}

variable "retention_in_days" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days"
  type        = number
  default     = 365
}

variable "environment" {
  description = "Map of configuration values to be converted into ECS native format"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html#secrets-envvar-parameters"
  type        = map(string)
  default     = {}
}

variable "kms_secrets" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets"
  type        = map(string)
  default     = {}
}

variable "deregistration_delay" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#deregistration_delay"
  default     = 30
  type        = number
}
variable "healthy_threshold" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#healthy_threshold"
  default     = 2
  type        = number
}

variable "unhealthy_threshold" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#unhealthy_threshold"
  default     = 10
  type        = number
}

variable "interval" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#interval"
  default     = 15
  type        = number
}

variable "timeout" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#timeout"
  default     = 5
  type        = number
}

variable "enable_lambda_cw_alert" {
  description = "enable lambda cloudwatch alert"
  type        = bool
  default     = false
}

variable "filter_pattern" {
  description = "https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html#extract-log-event-values"
  type        = string
  default     = "ERROR"
}

variable "slack_url" {
  description = "slack url"
  type        = string
  default     = "https://hooks.slack.com/services/abc123"
}

variable "alert_region" {
  description = "region of cloudwatch alarm"
  type        = string
  default     = "us-east-2"
}

variable "max_capacity" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#max_capacity"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#min_capacity"
  type        = number
  default     = 1
}

variable "autoscaling_target_value" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_value"
  type        = number
  default     = 75
}

variable "scale_in_cooldown" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_in_cooldown"
  type        = number
  default     = 60
}

variable "scale_out_cooldown" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_out_cooldown"
  type        = number
  default     = 60
}

variable "autoscaling_predefined_metric_type" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#predefined_metric_type"
  type        = string
  default     = "ECSServiceAverageCPUUtilization"
}

variable "autoscaling_policy_type" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#policy_type"
  type        = string
  default     = "TargetTrackingScaling"
}

variable "deployment_maximum_percent" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_maximum_percent"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_minimum_healthy_percent"
  type        = number
  default     = 100
}

variable "deployment_circuit_breaker_enable" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable"
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#rollback"
  type        = bool
  default     = true
}

variable "command" {
  description = "optional command entrypoint for container task definition"
  type        = list(string)
  default     = null
}

variable "stickiness" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#stickiness"
  type        = list(map(any))
  default     = null
}

variable "source_ips" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#source_ip"
  type        = list(any)
  default     = []
}

variable "enable_route53_health_check" {
  description = "Create Route 53 health check"
  type        = bool
  default     = false
}

variable "enable_public_healthcheck_rule" {
  description = "Create a rule on the load balancer to allow public healthcheck requests using a secret token"
  type        = bool
  default     = false
}

variable "health_check_type" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#type"
  type        = string
  default     = "HTTPS"
}

variable "health_check_port" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#port"
  type        = number
  default     = 443
}

variable "overwrite_ssm" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter.html#overwrite"
  type        = bool
  default     = true
}

variable "healthcheck_query_parameter" {
  description = "URL query parameter name needed to call the healthcheck"
  type        = string
  default     = "secret"
}

variable "enable_authenticate_oidc" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authenticate_oidc"
  type        = bool
  default     = false
}

variable "oidc_authentication_request_extra_params" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authentication_request_extra_params"
  type        = map(string)
  default     = null
}

variable "oidc_authorization_endpoint" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authorization_endpoint"
  type        = string
  default     = null
}

variable "oidc_client_id" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#client_id"
  type        = string
  default     = null
}

variable "oidc_client_secret" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#client_secret"
  type        = string
  default     = null
}

variable "oidc_issuer" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#issuer"
  type        = string
  default     = null
}

variable "oidc_on_unauthenticated_request" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#on_unauthenticated_request"
  type        = string
  default     = null
}

variable "oidc_scope" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#scope"
  type        = string
  default     = null
}

variable "oidc_session_cookie_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_cookie_name"
  type        = string
  default     = null
}

variable "oidc_session_timeout" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_timeout"
  type        = string
  default     = null
}

variable "oidc_token_endpoint" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#token_endpoint"
  type        = string
  default     = null
}

variable "oidc_user_info_endpoint" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_info_endpoint"
  type        = string
  default     = null
}

variable "enable_authenticate_cognito" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authenticate_cognito"
  type        = bool
  default     = false
}

variable "cognito_authentication_request_extra_params" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authentication_request_extra_params"
  type        = map(string)
  default     = null
}

variable "cognito_on_unauthenticated_request" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#on_unauthenticated_request"
  type        = string
  default     = null
}

variable "cognito_scope" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#scope"
  type        = string
  default     = null
}

variable "cognito_session_cookie_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_cookie_name"
  type        = string
  default     = null
}

variable "cognito_session_timeout" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_timeout"
  type        = string
  default     = null
}

variable "cognito_user_pool_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_arn"
  type        = string
  default     = null
}

variable "cognito_user_pool_client_id" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_client_id"
  type        = string
  default     = null
}

variable "cognito_user_pool_domain" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_domain"
  type        = string
  default     = null
}

variable "enable_wait_for_ecr" {
  description = "Wait for ECR image tag to become available"
  type        = bool
  default     = false
}

variable "alb_arn_suffix" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#resource_id"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "memory_avg_utilization_threshold" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_tracking_scaling_policy_configuration"
  type        = number
  default     = 80
}

variable "cpu_avg_utilization_threshold" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_tracking_scaling_policy_configuration"
  type        = number
  default     = 80
}

variable "metric_alarms_enabled" {
  description = "Enable metric alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm#alarm_actions"
  type        = string
  default     = ""
}

variable "enable_ecs_auto_update" {
  description = "Enable ECS auto update"
  type        = bool
  default     = false
}

variable "ecs_slack_notification_lambda" {
  description = "Slack notification lambda"
  type        = string
  default     = "ecs-slack-notification"
}

variable "ecs_slack_channel" {
  description = "Slack channel"
  type        = string
  default     = ""
}

variable "runtime_platform" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#runtime_platform"
  type        = map(string)
  default     = null
}
