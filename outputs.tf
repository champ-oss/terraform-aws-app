output "task_definition_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#arn"
  value       = aws_ecs_task_definition.this.arn
}

output "cloudwatch_log_group_name" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#name"
  value       = aws_cloudwatch_log_group.this.name
}

output "target_group_arn" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#arn"
  value       = aws_lb_target_group.this.arn
}

output "aws_ssm_parameter_names" {
  description = "List of SSM parameter names"
  value       = [for param in aws_ssm_parameter.this : param.name]
}

output "route53_health_check_resource_path" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#resource_path"
  sensitive   = true
  value       = var.enable_route53_health_check ? local.route53_health_check_resource_path : null
}

output "r53_health_check_id" {
  description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check#id"
  value       = var.enable_route53_health_check ? module.route53_health_check[0].r53_health_check_id : null
}
