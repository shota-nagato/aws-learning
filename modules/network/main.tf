resource "aws_vpc" "main" {
  cidr_block           = var.network.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.common.prefix}-${var.common.env}-vpc"
  }
}

locals {
  subnets = merge([
    for group_name, group in var.network.subnet_groups : {
      for subnet in group.subnets : "${group_name}-${subnet.az}" => {
        type = group.visibility
        tier = group.tier
        az   = subnet.az
        cidr = subnet.cidr
      }
    }
  ]...)
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr

  tags = {
    Name = "${var.common.prefix}-${var.common.env}-${each.value.type}-${each.value.tier}-subnet-1${each.value.az}"
  }
}
