# terraform-aws-app

A Terraform module for creating an AWS ECS Service

[![.github/workflows/module.yml](https://github.com/champ-oss/terraform-aws-app/actions/workflows/module.yml/badge.svg?branch=main)](https://github.com/champ-oss/terraform-aws-app/actions/workflows/module.yml)
[![.github/workflows/lint.yml](https://github.com/champ-oss/terraform-aws-app/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/champ-oss/terraform-aws-app/actions/workflows/lint.yml)
[![.github/workflows/sonar.yml](https://github.com/champ-oss/terraform-aws-app/actions/workflows/sonar.yml/badge.svg)](https://github.com/champ-oss/terraform-aws-app/actions/workflows/sonar.yml)

[![SonarCloud](https://sonarcloud.io/images/project_badges/sonarcloud-black.svg)](https://sonarcloud.io/summary/new_code?id=terraform-aws-app_champ-oss)

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=terraform-aws-app_champ-oss&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=terraform-aws-app_champ-oss)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=terraform-aws-app_champ-oss&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=terraform-aws-app_champ-oss)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=terraform-aws-app_champ-oss&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=terraform-aws-app_champ-oss)

## Example Usage

See details in the `examples/` folder

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.19.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_cloudwatch_alert"></a> [lambda\_cloudwatch\_alert](#module\_lambda\_cloudwatch\_alert) | github.com/champ-oss/terraform-aws-alert.git | v1.0.154-a2c8b37 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_event_rule.ecs_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.trigger_step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.send_to_central_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.step_function_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.cpu_avg_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_avg_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_service.disabled_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy.invoke_step_functions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.put_events_to_central](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eventbridge_cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eventbridge_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_functions_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_put_events_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_update_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.invoke_step_functions_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.public_healthcheck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_health_check.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.efs_from_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sfn_state_machine.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_ssm_parameter.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [null_resource.wait_for_ecr](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.healthcheck](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_kms_secrets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_arn_suffix"></a> [alb\_arn\_suffix](#input\_alb\_arn\_suffix) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#resource_id | `string` | `""` | no |
| <a name="input_alert_region"></a> [alert\_region](#input\_alert\_region) | region of cloudwatch alarm | `string` | `"us-east-2"` | no |
| <a name="input_autoscaling_policy_type"></a> [autoscaling\_policy\_type](#input\_autoscaling\_policy\_type) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#policy_type | `string` | `"TargetTrackingScaling"` | no |
| <a name="input_autoscaling_predefined_metric_type"></a> [autoscaling\_predefined\_metric\_type](#input\_autoscaling\_predefined\_metric\_type) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#predefined_metric_type | `string` | `"ECSServiceAverageCPUUtilization"` | no |
| <a name="input_autoscaling_target_value"></a> [autoscaling\_target\_value](#input\_autoscaling\_target\_value) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_value | `number` | `75` | no |
| <a name="input_availability_zone_rebalancing"></a> [availability\_zone\_rebalancing](#input\_availability\_zone\_rebalancing) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#availability_zone_rebalancing-1 | `string` | `null` | no |
| <a name="input_central_bus"></a> [central\_bus](#input\_central\_bus) | ARN of the central EventBridge bus to send ECS deployment events to. Required if enable\_ecs\_observability is true. | `string` | `""` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#cluster | `string` | n/a | yes |
| <a name="input_cognito_authentication_request_extra_params"></a> [cognito\_authentication\_request\_extra\_params](#input\_cognito\_authentication\_request\_extra\_params) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authentication_request_extra_params | `map(string)` | `null` | no |
| <a name="input_cognito_on_unauthenticated_request"></a> [cognito\_on\_unauthenticated\_request](#input\_cognito\_on\_unauthenticated\_request) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#on_unauthenticated_request | `string` | `null` | no |
| <a name="input_cognito_scope"></a> [cognito\_scope](#input\_cognito\_scope) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#scope | `string` | `null` | no |
| <a name="input_cognito_session_cookie_name"></a> [cognito\_session\_cookie\_name](#input\_cognito\_session\_cookie\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_cookie_name | `string` | `null` | no |
| <a name="input_cognito_session_timeout"></a> [cognito\_session\_timeout](#input\_cognito\_session\_timeout) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_timeout | `string` | `null` | no |
| <a name="input_cognito_user_pool_arn"></a> [cognito\_user\_pool\_arn](#input\_cognito\_user\_pool\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_arn | `string` | `null` | no |
| <a name="input_cognito_user_pool_client_id"></a> [cognito\_user\_pool\_client\_id](#input\_cognito\_user\_pool\_client\_id) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_client_id | `string` | `null` | no |
| <a name="input_cognito_user_pool_domain"></a> [cognito\_user\_pool\_domain](#input\_cognito\_user\_pool\_domain) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_pool_domain | `string` | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | optional command entrypoint for container task definition | `list(string)` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `256` | no |
| <a name="input_cpu_avg_utilization_threshold"></a> [cpu\_avg\_utilization\_threshold](#input\_cpu\_avg\_utilization\_threshold) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_tracking_scaling_policy_configuration | `number` | `80` | no |
| <a name="input_deployment_circuit_breaker_enable"></a> [deployment\_circuit\_breaker\_enable](#input\_deployment\_circuit\_breaker\_enable) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable | `bool` | `true` | no |
| <a name="input_deployment_circuit_breaker_rollback"></a> [deployment\_circuit\_breaker\_rollback](#input\_deployment\_circuit\_breaker\_rollback) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#rollback | `bool` | `true` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_maximum_percent | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#deployment_minimum_healthy_percent | `number` | `100` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#deregistration_delay | `number` | `30` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count | `number` | `null` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#name | `string` | `""` | no |
| <a name="input_ecs_slack_channel"></a> [ecs\_slack\_channel](#input\_ecs\_slack\_channel) | Slack channel | `string` | `""` | no |
| <a name="input_ecs_slack_notification_lambda"></a> [ecs\_slack\_notification\_lambda](#input\_ecs\_slack\_notification\_lambda) | Slack notification lambda | `string` | `"ecs-slack-notification"` | no |
| <a name="input_efs_mounts"></a> [efs\_mounts](#input\_efs\_mounts) | List of EFS mounts to create and attach to ECS task definition | <pre>list(object({<br/>    path           = string<br/>    container_path = string<br/>    read_only      = optional(bool, false)<br/><br/>    user = optional(object({<br/>      uid = number<br/>      gid = number<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_authenticate_cognito"></a> [enable\_authenticate\_cognito](#input\_enable\_authenticate\_cognito) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authenticate_cognito | `bool` | `false` | no |
| <a name="input_enable_authenticate_oidc"></a> [enable\_authenticate\_oidc](#input\_enable\_authenticate\_oidc) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authenticate_oidc | `bool` | `false` | no |
| <a name="input_enable_ecs_auto_update"></a> [enable\_ecs\_auto\_update](#input\_enable\_ecs\_auto\_update) | Enable ECS auto update | `bool` | `false` | no |
| <a name="input_enable_ecs_observability"></a> [enable\_ecs\_observability](#input\_enable\_ecs\_observability) | Enable ECS observability with CloudWatch Container Insights | `bool` | `false` | no |
| <a name="input_enable_efs"></a> [enable\_efs](#input\_enable\_efs) | Enable EFS volume for ECS tasks | `bool` | `false` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable_execute_command | `bool` | `false` | no |
| <a name="input_enable_lambda_cw_alert"></a> [enable\_lambda\_cw\_alert](#input\_enable\_lambda\_cw\_alert) | enable lambda cloudwatch alert | `bool` | `false` | no |
| <a name="input_enable_load_balancer"></a> [enable\_load\_balancer](#input\_enable\_load\_balancer) | enable load balancer | `bool` | `true` | no |
| <a name="input_enable_public_healthcheck_rule"></a> [enable\_public\_healthcheck\_rule](#input\_enable\_public\_healthcheck\_rule) | Create a rule on the load balancer to allow public healthcheck requests using a secret token | `bool` | `false` | no |
| <a name="input_enable_route53"></a> [enable\_route53](#input\_enable\_route53) | Create Route 53 record | `bool` | `true` | no |
| <a name="input_enable_route53_health_check"></a> [enable\_route53\_health\_check](#input\_enable\_route53\_health\_check) | Create Route 53 health check | `bool` | `false` | no |
| <a name="input_enable_wait_for_ecr"></a> [enable\_wait\_for\_ecr](#input\_enable\_wait\_for\_ecr) | Wait for ECR image tag to become available | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Map of configuration values to be converted into ECS native format | `map(string)` | `{}` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#execution_role_arn | `string` | `""` | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html#extract-log-event-values | `string` | `"ERROR"` | no |
| <a name="input_git"></a> [git](#input\_git) | Exact name of your git repository | `string` | n/a | yes |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#health_check_grace_period_seconds | `number` | `30` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#port | `number` | `443` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#type | `string` | `"HTTPS"` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#path | `string` | `"/"` | no |
| <a name="input_healthcheck_query_parameter"></a> [healthcheck\_query\_parameter](#input\_healthcheck\_query\_parameter) | URL query parameter name needed to call the healthcheck | `string` | `"secret"` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#healthy_threshold | `number` | `2` | no |
| <a name="input_image"></a> [image](#input\_image) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_image | `string` | n/a | yes |
| <a name="input_interval"></a> [interval](#input\_interval) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#interval | `number` | `15` | no |
| <a name="input_kms_secrets"></a> [kms\_secrets](#input\_kms\_secrets) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets | `map(string)` | `{}` | no |
| <a name="input_lb_dns_name"></a> [lb\_dns\_name](#input\_lb\_dns\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#dns_name | `string` | `""` | no |
| <a name="input_lb_zone_id"></a> [lb\_zone\_id](#input\_lb\_zone\_id) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#zone_id | `string` | `""` | no |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#listener_arn | `string` | `""` | no |
| <a name="input_matcher"></a> [matcher](#input\_matcher) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#matcher | `string` | `"200,301,302"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#max_capacity | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `512` | no |
| <a name="input_memory_avg_utilization_threshold"></a> [memory\_avg\_utilization\_threshold](#input\_memory\_avg\_utilization\_threshold) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_tracking_scaling_policy_configuration | `number` | `80` | no |
| <a name="input_metric_alarms_enabled"></a> [metric\_alarms\_enabled](#input\_metric\_alarms\_enabled) | Enable metric alarms | `bool` | `false` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#min_capacity | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique identifier for naming resources | `string` | n/a | yes |
| <a name="input_oidc_authentication_request_extra_params"></a> [oidc\_authentication\_request\_extra\_params](#input\_oidc\_authentication\_request\_extra\_params) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authentication_request_extra_params | `map(string)` | `null` | no |
| <a name="input_oidc_authorization_endpoint"></a> [oidc\_authorization\_endpoint](#input\_oidc\_authorization\_endpoint) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#authorization_endpoint | `string` | `null` | no |
| <a name="input_oidc_client_id"></a> [oidc\_client\_id](#input\_oidc\_client\_id) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#client_id | `string` | `null` | no |
| <a name="input_oidc_client_secret"></a> [oidc\_client\_secret](#input\_oidc\_client\_secret) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#client_secret | `string` | `null` | no |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#issuer | `string` | `null` | no |
| <a name="input_oidc_on_unauthenticated_request"></a> [oidc\_on\_unauthenticated\_request](#input\_oidc\_on\_unauthenticated\_request) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#on_unauthenticated_request | `string` | `null` | no |
| <a name="input_oidc_scope"></a> [oidc\_scope](#input\_oidc\_scope) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#scope | `string` | `null` | no |
| <a name="input_oidc_session_cookie_name"></a> [oidc\_session\_cookie\_name](#input\_oidc\_session\_cookie\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_cookie_name | `string` | `null` | no |
| <a name="input_oidc_session_timeout"></a> [oidc\_session\_timeout](#input\_oidc\_session\_timeout) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#session_timeout | `string` | `null` | no |
| <a name="input_oidc_token_endpoint"></a> [oidc\_token\_endpoint](#input\_oidc\_token\_endpoint) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#token_endpoint | `string` | `null` | no |
| <a name="input_oidc_user_info_endpoint"></a> [oidc\_user\_info\_endpoint](#input\_oidc\_user\_info\_endpoint) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#user_info_endpoint | `string` | `null` | no |
| <a name="input_overwrite_ssm"></a> [overwrite\_ssm](#input\_overwrite\_ssm) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter.html#overwrite | `bool` | `true` | no |
| <a name="input_path_pattern_regex_values"></a> [path\_pattern\_regex\_values](#input\_path\_pattern\_regex\_values) | List of regex path patterns for the load balancer. Cannot be combined with path\_patterns. https://docs.aws.amazon.com/elasticloadbalancing/latest/application/rule-condition-types.html#path-conditions | `list(string)` | `[]` | no |
| <a name="input_path_patterns"></a> [path\_patterns](#input\_path\_patterns) | List of path patterns for the load balancer | `list(string)` | `[]` | no |
| <a name="input_paused"></a> [paused](#input\_paused) | Pause resources | `bool` | `false` | no |
| <a name="input_port"></a> [port](#input\_port) | Port number of the service running inside your container | `number` | `8080` | no |
| <a name="input_read_only_root_file_system"></a> [read\_only\_root\_file\_system](#input\_read\_only\_root\_file\_system) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ ecs\_task\_definition#execution\_role\_arn | `bool` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days | `number` | `365` | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#runtime_platform | `map(string)` | `null` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_in_cooldown | `number` | `60` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_out_cooldown | `number` | `60` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html#secrets-envvar-parameters | `map(string)` | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#security_groups | `list(string)` | `[]` | no |
| <a name="input_slack_url"></a> [slack\_url](#input\_slack\_url) | slack url | `string` | `"https://hooks.slack.com/services/abc123"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm#alarm_actions | `string` | `""` | no |
| <a name="input_source_ips"></a> [source\_ips](#input\_source\_ips) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#source_ip | `list(any)` | `[]` | no |
| <a name="input_stickiness"></a> [stickiness](#input\_stickiness) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#stickiness | `list(map(any))` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#subnets | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#timeout | `number` | `5` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#unhealthy_threshold | `number` | `10` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#vpc_id | `string` | n/a | yes |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#wait_for_steady_state | `bool` | `true` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ssm_parameter_names"></a> [aws\_ssm\_parameter\_names](#output\_aws\_ssm\_parameter\_names) | List of SSM parameter names |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#name |
| <a name="output_dns_endpoint"></a> [dns\_endpoint](#output\_dns\_endpoint) | output dns endpoint |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | output service name |
| <a name="output_route53_health_check_resource_path"></a> [route53\_health\_check\_resource\_path](#output\_route53\_health\_check\_resource\_path) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#resource_path |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#arn |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#arn |
<!-- END_TF_DOCS -->

## Features



## Contributing

