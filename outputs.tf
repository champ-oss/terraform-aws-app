output "task_definition_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#arn"
  value       = var.enabled && !var.enable_source_ecr_event_bridge_rule ? aws_ecs_task_definition.this[0].arn : ""
}

output "cloudwatch_log_group_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#name"
  value       = var.enabled && !var.enable_source_ecr_event_bridge_rule ? aws_cloudwatch_log_group.this[0].name : ""
}

output "target_group_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#arn"
  value       = var.enabled && !var.enable_source_ecr_event_bridge_rule ? aws_lb_target_group.this[0].arn : ""
}

output "aws_ssm_parameter_names" {
  description = "List of SSM parameter names"
  value       = var.enabled && !var.enable_source_ecr_event_bridge_rule ? [for param in aws_ssm_parameter.this : param.name] : []
}

output "route53_health_check_resource_path" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#resource_path"
  sensitive   = true
  value       = var.enable_route53_health_check && var.enabled && !var.enable_source_ecr_event_bridge_rule ? local.route53_health_check_resource_path : ""
}

output "dns_endpoint" {
  description = "output dns endpoint"
  value       = var.enable_route53 && var.enabled && !var.enable_source_ecr_event_bridge_rule ? aws_route53_record.this[0].name : null
}
