resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.common.prefix}-vpc"
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(var.common.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(var.common.availability_zones, each.value))

  tags = {
    Name = "${var.common.prefix}-private-subnet-1${each.value}"
  }
}

resource "aws_subnet" "public" {
  for_each          = toset(var.common.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value}"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(var.common.availability_zones, each.value) + length(var.common.availability_zones))

  tags = {
    Name = "${var.common.prefix}-public-subnet-1${each.value}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.prefix}-igw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.prefix}-private-rtb"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.prefix}-public-rtb"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "frontend" {
  name   = "${var.common.prefix}-frontend-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.prefix}-frontend-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend_http" {
  security_group_id = aws_security_group.frontend.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "frontend_all" {
  security_group_id = aws_security_group.frontend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
