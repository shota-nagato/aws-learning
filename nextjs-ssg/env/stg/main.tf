terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

data "aws_route53_zone" "main" {
  name = var.domain_settings.base_domain
}

module "acm" {
  source = "../../modules/acm"

  project_settings = var.project_settings
  domain_settings = {
    domain_name = local.domain_name
    zone_id     = data.aws_route53_zone.main.zone_id
  }
}

module "s3" {
  source = "../../modules/s3"

  project_settings            = var.project_settings
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  project_settings = var.project_settings
  domain_settings = {
    domain_name = local.domain_name
    zone_id     = data.aws_route53_zone.main.zone_id
  }
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  bucket_origin_id            = module.s3.bucket_origin_id
  acm_certificate_arn         = module.acm.acm_certificate_arn
}

module "cicd_iam" {
  source = "../../modules/cicd_iam"

  project_settings = var.project_settings
  cicd_settings = {
    github_repository = var.cicd_settings.github_repository
    branch_name       = var.cicd_settings.branch_name
    bucket_arn        = module.s3.bucket_arn
  }
}
