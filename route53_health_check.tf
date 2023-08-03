module "route53_health_check" {
  count         = var.enable_route53_health_check ? 1 : 0
  source        = "github.com/champ-oss/terraform-aws-route53-health-check.git?ref=v1.0.2-9eb134a"
  git           = var.git
  type          = var.health_check_type
  port          = var.health_check_port
  tags          = merge(local.tags, var.tags)
  fqdn          = aws_route53_record.this[0].name
  resource_path = aws_lb_target_group.this.health_check[0].path
  alarms_email  = var.health_check_alarms_email
}
