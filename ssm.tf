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

