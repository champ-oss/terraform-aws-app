locals {
  git = "terraform-aws-app"
  tags = {
    git     = local.git
    cost    = "shared"
    creator = "terraform"
  }
}

provider "aws" {
  region = "us-west-1"
}

data "aws_route53_zone" "this" {
  name = "oss.champtest.net."
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  number  = true
}

module "vpc" {
  source                   = "github.com/champ-oss/terraform-aws-vpc.git?ref=v1.0.24-900228d"
  git                      = local.git
  availability_zones_count = 2
  retention_in_days        = 1
  create_private_subnets   = true
}

module "acm" {
  source            = "github.com/champ-oss/terraform-aws-acm.git?ref=v1.0.78-5dcdfa2"
  git               = local.git
  domain_name       = "${local.git}.${data.aws_route53_zone.this.name}"
  create_wildcard   = false
  zone_id           = data.aws_route53_zone.this.zone_id
  enable_validation = true
}

module "core" {
  source                    = "github.com/champ-oss/terraform-aws-core.git?ref=v1.0.69-97c8707"
  git                       = local.git
  name                      = local.git
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnets_ids
  private_subnet_ids        = module.vpc.private_subnets_ids
  protect                   = false
  log_retention             = "3"
  tags                      = local.tags
  certificate_arn           = module.acm.arn
  enable_container_insights = false
}

module "kms" {
  source                  = "github.com/champ-oss/terraform-aws-kms.git?ref=v1.0.17-cdc599d"
  git                     = local.git
  name                    = "alias/${local.git}-${random_string.this.result}"
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
  name  = "${local.git}-${random_string.this.result}-1"
  type  = "SecureString"
  value = "ssm secret 1"
  tags  = local.tags
}

resource "aws_ssm_parameter" "secret2" {
  name  = "${local.git}-${random_string.this.result}-2"
  type  = "SecureString"
  value = "ssm secret 2"
  tags  = local.tags
}

module "this" {
  source             = "../../"
  git                = local.git
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets_ids
  zone_id            = data.aws_route53_zone.this.zone_id
  cluster            = module.core.ecs_cluster_name
  security_groups    = [module.core.ecs_app_security_group]
  execution_role_arn = module.core.execution_ecs_role_arn
  listener_arn       = module.core.lb_public_listener_arn
  lb_dns_name        = module.core.lb_public_dns_name
  lb_zone_id         = module.core.lb_public_zone_id
  enable_route53     = true

  # app specific variables
  name                              = "test"
  dns_name                          = "${local.git}.${data.aws_route53_zone.this.name}"
  image                             = "testcontainers/helloworld"
  healthcheck                       = "/"
  port                              = 8080
  health_check_grace_period_seconds = 5
  deregistration_delay              = 5
  retention_in_days                 = 3
  enable_execute_command            = true

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

module "autoscale" {
  source               = "../../"
  git                  = local.git
  vpc_id               = module.vpc.vpc_id
  subnets              = module.vpc.private_subnets_ids
  zone_id              = data.aws_route53_zone.this.zone_id
  cluster              = module.core.ecs_cluster_name
  security_groups      = [module.core.ecs_app_security_group]
  execution_role_arn   = module.core.execution_ecs_role_arn
  enable_load_balancer = false
  enable_route53       = false
  name                 = "autoscale"
  image                = "danielsantos/cpustress"
  cpu                  = 256
  memory               = 512
  scale_in_cooldown    = 30
  scale_out_cooldown   = 30
  min_capacity         = 1
  max_capacity         = 10
}