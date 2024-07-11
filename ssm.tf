locals {
  ssm_prefix = "/${var.git}/kms/${var.name}/"
}

data "aws_kms_secrets" "this" {
  for_each = var.kms_secrets
  secret {
    name    = each.key
    payload = each.value
  }
}

resource "aws_ssm_parameter" "this" {
  for_each    = data.aws_kms_secrets.this
  description = "Do not modify. Managed by Terraform from terraform-aws-app"
  name        = "${local.ssm_prefix}${each.key}"
  type        = "SecureString"
  value       = each.value.plaintext[each.key]
  overwrite   = var.overwrite_ssm
  tags        = merge(local.tags, var.tags)
}

resource "aws_ssm_parameter" "dns" {
  count       = var.enable_route53 && var.enabled ? 1 : 0
  name        = "/${var.git}/dns/${aws_route53_record.this[0].name}"
  description = "gathering route53 info"
  type        = "SecureString"
  value       = aws_route53_record.this[0].name
  overwrite   = var.overwrite_ssm
  tags = merge({
    dns_endpoint = aws_route53_record.this[0].name
    dns_path     = try(aws_lb_target_group.this[0].health_check[0].path, "")
  }, local.tags, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

