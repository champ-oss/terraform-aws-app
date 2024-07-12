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

variable "enabled" {
  description = "module enabled"
  type        = bool
  default     = false
}

module "acm" {
  source            = "github.com/champ-oss/terraform-aws-acm.git?ref=v1.0.117-6aa9478"
  git               = local.git
  domain_name       = "${local.git}.${data.aws_route53_zone.this.name}"
  create_wildcard   = false
  zone_id           = data.aws_route53_zone.this.zone_id
  enable_validation = true
  enabled           = var.enabled
}

module "core" {
  source                    = "github.com/champ-oss/terraform-aws-core.git?ref=v1.0.119-061bf8b"
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
  enabled                   = var.enabled
}

module "kms" {
  source                  = "github.com/champ-oss/terraform-aws-kms.git?ref=v1.0.34-a5b529e"
  git                     = local.git
  name                    = "alias/${local.git}-${random_id.this.hex}"
  deletion_window_in_days = 7
  account_actions         = []
  enabled                 = var.enabled
}

module "this" {
  source                            = "../../"
  git                               = local.git
  vpc_id                            = data.aws_vpcs.this.ids[0]
  subnets                           = data.aws_subnets.private.ids
  zone_id                           = data.aws_route53_zone.this.zone_id
  cluster                           = module.core.ecs_cluster_name
  security_groups                   = [module.core.ecs_app_security_group]
  execution_role_arn                = module.core.execution_ecs_role_arn
  listener_arn                      = module.core.lb_public_listener_arn
  lb_dns_name                       = module.core.lb_public_dns_name
  lb_zone_id                        = module.core.lb_public_zone_id
  enable_route53                    = true
  enable_route53_health_check       = true
  enable_public_healthcheck_rule    = true
  enabled                           = var.enabled
  name                              = "test"
  dns_name                          = "${local.git}.${data.aws_route53_zone.this.name}"
  image                             = "testcontainers/helloworld"
  healthcheck                       = "/ping"
  port                              = 8080
  health_check_grace_period_seconds = 5
  deregistration_delay              = 5
  retention_in_days                 = 3
  enable_execute_command            = true
  source_ips = [
    "1.1.1.1/32",
    "1.1.1.2/32",
    "1.1.1.3/32",
    "1.1.1.4/32",
    "1.1.1.5/32",
    "1.1.1.6/32"
  ]
}

output "dns_name" {
  description = "DNS host for ECS app"
  value       = "${local.git}.${data.aws_route53_zone.this.name}"
}

output "route53_health_check_resource_path" {
  description = "Path for healthcheck including secret"
  sensitive   = true
  value       = module.this.route53_health_check_resource_path
}

output "enabled" {
  description = "module enabled"
  value       = var.enabled
}
