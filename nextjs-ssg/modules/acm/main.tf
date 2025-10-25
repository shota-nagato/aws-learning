provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.useast1

  domain_name               = var.domain_settings.domain_name
  subject_alternative_names = ["*.${var.domain_settings.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_settings.project}-${var.project_settings.environment}-acm"
  }
}

resource "aws_route53_record" "acm_cloudfront" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  zone_id         = var.domain_settings.zone_id
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.useast1

  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_cloudfront : record.fqdn]
}
