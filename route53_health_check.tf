provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

module "route53_health_check" {
  count  = var.enable_route53_health_check && aws_appautoscaling_target.this.min_capacity != 0 ? 1 : 0
  source = "github.com/champ-oss/terraform-aws-route53-health-check.git?ref=v1.0.6-ee66457"
  providers = {
    aws = aws.virginia
  }
  git  = var.git
  type = var.health_check_type
  port = var.health_check_port
  tags = merge(local.tags, var.tags, local.name_tag)
  fqdn = try(aws_route53_record.this[0].name, "fallback")
  resource_path = (
    var.enable_public_healthcheck_rule ?
    "${aws_lb_target_group.this.health_check[0].path}?${var.healthcheck_query_parameter}=${random_password.healthcheck[0].result}" :
    aws_lb_target_group.this.health_check[0].path
  )
}
