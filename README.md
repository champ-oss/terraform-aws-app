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

See the `examples/` folder

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.71.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.71.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_cloudwatch_alert"></a> [lambda\_cloudwatch\_alert](#module\_lambda\_cloudwatch\_alert) | github.com/champ-oss/terraform-aws-alert.git | v1.0.93-d6bac8b |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.disabled_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_kms_secrets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_secrets) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_region"></a> [alert\_region](#input\_alert\_region) | region of cloudwatch alarm | `string` | `"us-east-2"` | no |
| <a name="input_autoscaling_target_cpu"></a> [autoscaling\_target\_cpu](#input\_autoscaling\_target\_cpu) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#target_value | `number` | `75` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#cluster | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `256` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#deregistration_delay | `number` | `30` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count | `number` | `null` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#name | `string` | `""` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable_execute_command | `bool` | `false` | no |
| <a name="input_enable_lambda_cw_alert"></a> [enable\_lambda\_cw\_alert](#input\_enable\_lambda\_cw\_alert) | enable lambda cloudwatch alert | `bool` | `false` | no |
| <a name="input_enable_load_balancer"></a> [enable\_load\_balancer](#input\_enable\_load\_balancer) | enable load balancer | `bool` | `true` | no |
| <a name="input_enable_route53"></a> [enable\_route53](#input\_enable\_route53) | Create Route 53 record | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Map of configuration values to be converted into ECS native format | `map(string)` | `{}` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#execution_role_arn | `string` | `""` | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html#extract-log-event-values | `string` | `"ERROR"` | no |
| <a name="input_git"></a> [git](#input\_git) | Exact name of your git repository | `string` | n/a | yes |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#health_check_grace_period_seconds | `number` | `30` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#path | `string` | `"/"` | no |
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
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target#min_capacity | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique identifier for naming resources | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port number of the service running inside your container | `number` | `8080` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days | `number` | `365` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_in_cooldown | `number` | `60` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy#scale_out_cooldown | `number` | `60` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html#secrets-envvar-parameters | `map(string)` | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#security_groups | `list(string)` | `[]` | no |
| <a name="input_slack_url"></a> [slack\_url](#input\_slack\_url) | slack url | `string` | `"https://hooks.slack.com/services/abc123"` | no |
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
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#name |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#arn |
<!-- END_TF_DOCS -->

## Features



## Contributing


