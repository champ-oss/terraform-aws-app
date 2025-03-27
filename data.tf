data "aws_region" "this" {
  count = var.enabled ? 1 : 0
}

# data resource for this account
data "aws_caller_identity" "this" {
  count = var.enabled ? 1 : 0
}