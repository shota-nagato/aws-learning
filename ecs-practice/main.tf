terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

locals {
  common = {
    prefix             = "ecs-practice"
    region             = "ap-northeast-1"
    availability_zones = ["a"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.common.prefix}-vpc"
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(local.common.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = "${local.common.region}${each.value}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(local.common.availability_zones, each.value))

  tags = {
    Name = "${local.common.prefix}-private-subnet-1${each.value}"
  }
}

resource "aws_subnet" "public" {
  for_each          = toset(local.common.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = "${local.common.region}${each.value}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(local.common.availability_zones, each.value) + length(local.common.availability_zones))

  tags = {
    Name = "${local.common.prefix}-public-subnet-1${each.value}"
  }
}
