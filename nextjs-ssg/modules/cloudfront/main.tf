resource "aws_cloudfront_origin_access_control" "next" {
  name                              = "${var.project_settings.project}-${var.project_settings.environment}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "next" {
  aliases             = [var.domain_settings.domain_name]
  enabled             = true
  comment             = "${var.project_settings.project}-${var.project_settings.environment}-cloudfront-distribution"
  default_root_object = "index.html"

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = "s3-${var.bucket_origin_id}"

    origin_access_control_id = aws_cloudfront_origin_access_control.next.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${var.bucket_origin_id}"

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_settings.project}-${var.project_settings.environment}-cloudfront-distribution"
  }
}

resource "aws_route53_record" "cloudfront" {
  zone_id = var.domain_settings.zone_id
  name    = var.domain_settings.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.next.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
