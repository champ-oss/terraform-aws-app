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

data "aws_route53_zone" "this" {
  name = "oss.champtest.net."
}

resource "random_id" "this" {
  byte_length = 2
}

module "acm" {
  source            = "github.com/champ-oss/terraform-aws-acm.git?ref=v1.0.114-1c756c3"
  git               = local.git
  domain_name       = "${local.git}.${data.aws_route53_zone.this.name}"
  create_wildcard   = false
  zone_id           = data.aws_route53_zone.this.zone_id
  enable_validation = true
}

module "core" {
  source                    = "github.com/champ-oss/terraform-aws-core.git?ref=v1.0.114-758b2d1"
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

module "autoscale" {
  source                             = "../../"
  git                                = local.git
  vpc_id                             = data.aws_vpcs.this.ids[0]
  subnets                            = data.aws_subnets.private.ids
  zone_id                            = data.aws_route53_zone.this.zone_id
  cluster                            = module.core.ecs_cluster_name
  security_groups                    = [module.core.ecs_app_security_group]
  execution_role_arn                 = module.core.execution_ecs_role_arn
  enable_ecs_request_count_autoscale = true
  enable_load_balancer               = false
  enable_route53                     = false
  name                               = "autoscale"
  image                              = "danielsantos/cpustress"
  cpu                                = 256
  memory                             = 512
  scale_in_cooldown                  = 30
  scale_out_cooldown                 = 30
  min_capacity                       = 1
  max_capacity                       = 10
}
