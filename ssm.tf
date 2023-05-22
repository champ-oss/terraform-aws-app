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
  tags        = merge(local.tags, var.tags)
}

resource "aws_ssm_parameter" "dns" {
  count       = var.enable_route53 ? 1 : 0
  name        = "/${var.git}/dns/${aws_route53_record.this[0].name}"
  description = "gathering dns data"
  type        = "SecureString"
  value       = var.dns_name
  tags = merge({
    dns_endpoint = aws_route53_record.this[0].name
  }, local.tags, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

