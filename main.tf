data "aws_region" "this" {}

locals {
  tags = {
    git       = var.git
    cost      = "shared"
    creator   = "terraform"
    component = var.name
  }
  name_tag = {
    Name = var.enable_route53_health_check != false ? aws_route53_record.this[0].name : null
  }
}

resource "random_password" "healthcheck" {
  count   = var.enable_public_healthcheck_rule ? 1 : 0
  length  = 32
  special = false
}

resource "null_resource" "wait_for_ecr" {
  count = var.enable_wait_for_ecr ? 1 : 0
  triggers = {
    image = var.image
  }
  provisioner "local-exec" {
    command     = "sh ${path.module}/wait_for_ecr.sh"
    interpreter = ["/bin/sh", "-c"]
    environment = {
      RETRIES    = 60
      SLEEP      = 10
      AWS_REGION = data.aws_region.this.name
      IMAGE      = var.image
    }
  }
}