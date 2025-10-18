locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"

  san_list = ["*.${var.acm_settings.domain_name}"]
}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.use1]
    }
  }
}

resource "aws_acm_certificate" "api" {
  domain_name               = var.acm_settings.domain_name
  subject_alternative_names = local.san_list
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.prefix}-acm-api"
  }
}

resource "aws_acm_certificate" "react_frontend" {
  provider                  = aws.use1
  domain_name               = var.acm_settings.domain_name
  subject_alternative_names = local.san_list
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.prefix}-acm-react-frontend"
  }
}

resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.acm_settings.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]

  allow_overwrite = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_route53_record" "react_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.react_frontend.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.acm_settings.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]

  allow_overwrite = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_acm_certificate_validation" "api_validation" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for r in aws_route53_record.api_cert_validation : r.fqdn]
}

resource "aws_acm_certificate_validation" "react_validation" {
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.react_frontend.arn
  validation_record_fqdns = [for r in aws_route53_record.react_cert_validation : r.fqdn]
}
