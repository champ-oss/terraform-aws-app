data "aws_region" "this" {}

locals {
  tags = {
    git       = var.git
    cost      = "shared"
    creator   = "terraform"
    component = var.name
  }
  name_tag = {
    name = enable_route53_health_check != false ? aws_route53_record.this[0].name : null
  }
}
