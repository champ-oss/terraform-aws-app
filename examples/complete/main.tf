terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

locals {
  git = "terraform-aws-app-${random_id.this.hex}"
  tags = {
    git     = local.git
    cost    = "shared"
    creator = "terraform"
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpcs" "this" {
  tags = {
    purpose = "vega"
  }
}

data "aws_subnets" "private" {
  tags = {
    purpose = "vega"
    Type    = "Private"
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.this.ids[0]]
  }
}

data "aws_subnets" "public" {
  tags = {
    purpose = "vega"
    Type    = "Public"
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.this.ids[0]]
  }
}

data "aws_route53_zone" "this" {
  name = "oss.champtest.net."
}

resource "random_id" "this" {
  byte_length = 2
}

module "acm" {
  source            = "github.com/champ-oss/terraform-aws-acm.git?ref=v1.0.116-cd36b2b"
  git               = local.git
  domain_name       = "${local.git}.${data.aws_route53_zone.this.name}"
  create_wildcard   = false
  zone_id           = data.aws_route53_zone.this.zone_id
  enable_validation = true
}

module "core" {
  source                    = "github.com/champ-oss/terraform-aws-core.git?ref=f2d757598b2ba38fbef4856f4567631e5d3a2855"
  git                       = local.git
  name                      = local.git
  vpc_id                    = data.aws_vpcs.this.ids[0]
  public_subnet_ids         = data.aws_subnets.public.ids
  private_subnet_ids        = data.aws_subnets.private.ids
  protect                   = false
  log_retention             = "3"
  tags                      = local.tags
  certificate_arn           = module.acm.arn
  enable_container_insights = false
}

module "kms" {
  source                  = "github.com/champ-oss/terraform-aws-kms.git?ref=v1.0.33-cb3be31"
  git                     = local.git
  name                    = "alias/${local.git}-${random_id.this.hex}"
  deletion_window_in_days = 7
  account_actions         = []
}

resource "aws_kms_ciphertext" "secret1" {
  key_id    = module.kms.key_id
  plaintext = "kms secret 1"
}

resource "aws_kms_ciphertext" "secret2" {
  key_id    = module.kms.key_id
  plaintext = "kms secret 2"
}

resource "aws_ssm_parameter" "secret1" {
  name  = "${local.git}-${random_id.this.hex}-1"
  type  = "SecureString"
  value = "ssm secret 1"
  tags  = local.tags
}

resource "aws_ssm_parameter" "secret2" {
  name  = "${local.git}-${random_id.this.hex}-2"
  type  = "SecureString"
  value = "ssm secret 2"
  tags  = local.tags
}

module "this" {
  source                      = "../../"
  git                         = local.git
  vpc_id                      = data.aws_vpcs.this.ids[0]
  subnets                     = data.aws_subnets.private.ids
  zone_id                     = data.aws_route53_zone.this.zone_id
  cluster                     = module.core.ecs_cluster_name
  security_groups             = [module.core.ecs_app_security_group]
  execution_role_arn          = module.core.execution_ecs_role_arn
  listener_arn                = module.core.lb_public_listener_arn
  lb_dns_name                 = module.core.lb_public_dns_name
  lb_zone_id                  = module.core.lb_public_zone_id
  enable_route53              = true
  enable_route53_health_check = true
  #
  /* stickiness example
  stickiness = [{
    enabled : true,
    type : "lb_cookie"
    cookie_duration : 43200,
  }]
  */

  # app specific variables
  name                               = "test"
  dns_name                           = "${local.git}.${data.aws_route53_zone.this.name}"
  image                              = "testcontainers/helloworld"
  healthcheck                        = "/ping"
  port                               = 8080
  health_check_grace_period_seconds  = 5
  deregistration_delay               = 5
  retention_in_days                  = 3
  enable_execute_command             = true
  autoscaling_predefined_metric_type = "ALBRequestCountPerTarget"
  autoscaling_target_value           = 50
  alb_arn_suffix                     = module.core.lb_public_arn_suffix
  min_capacity                       = 1
  max_capacity                       = 10
  scale_in_cooldown                  = 30
  scale_out_cooldown                 = 30

  environment = {
    this  = "that"
    these = "those"
  }

  secrets = {
    SSMTEST1 = aws_ssm_parameter.secret1.name
    SSMTEST2 = aws_ssm_parameter.secret2.name
  }

  kms_secrets = {
    KMSTEST1 = aws_kms_ciphertext.secret1.ciphertext_blob
    KMSTEST2 = aws_kms_ciphertext.secret2.ciphertext_blob

    # Test overriding a ssm "secret" with a "kms_secret"
    SSMTEST2 = aws_kms_ciphertext.secret2.ciphertext_blob
  }
}

output "dns_name" {
  description = "DNS host for ECS app"
  value       = "${local.git}.${data.aws_route53_zone.this.name}"
}

output "ssm_kms_test_1" {
  description = "SSM parameter name"
  value       = [for param in module.this.aws_ssm_parameter_names : param if endswith(param, "KMSTEST1")]
}

output "ssm_kms_test_2" {
  description = "SSM parameter name"
  value       = [for param in module.this.aws_ssm_parameter_names : param if endswith(param, "KMSTEST2")]
}

output "ssm_ssm_test_1" {
  description = "SSM parameter name"
  value       = [for param in module.this.aws_ssm_parameter_names : param if endswith(param, "SSMTEST2")]
}