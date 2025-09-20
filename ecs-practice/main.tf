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

module "network" {
  source = "./modules/network"

  common = local.common
}

module "ecs" {
  source = "./modules/ecs"

  common              = local.common
  network             = module.network
  alb_ingress         = module.alb_ingress
  lambda_function_arn = module.lambda.lambda_function_arn
}

module "ecr" {
  source = "./modules/ecr"

  common = local.common
}

module "alb_ingress" {
  source = "./modules/alb_ingress"

  common  = local.common
  network = module.network
}

module "lambda" {
  source = "./modules/lambda"

  common = local.common
}

