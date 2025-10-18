locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_s3_bucket" "react" {
  bucket = "${local.prefix}-react-hosting-20251018"

  tags = {
    Name = "${local.prefix}-react-hosting"
  }
}

resource "aws_s3_bucket_public_access_block" "react" {
  bucket = aws_s3_bucket.react.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "react" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.react.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.react.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "react" {
  bucket = aws_s3_bucket.react.id
  policy = data.aws_iam_policy_document.react.json
}

resource "aws_cloudfront_origin_access_control" "react" {
  name                              = "${local.prefix}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "react" {
  aliases             = [var.react_settings.domain_name]
  enabled             = true
  comment             = "React hosting for ${local.prefix}"
  default_root_object = "index.html"

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  origin {
    domain_name = aws_s3_bucket.react.bucket_regional_domain_name
    origin_id   = "s3-${aws_s3_bucket.react.id}"

    origin_access_control_id = aws_cloudfront_origin_access_control.react.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.react.id}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.react_settings.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    name = "${local.prefix}-react-cdn"
  }
}

resource "aws_route53_record" "react" {
  zone_id = var.react_settings.zone_id
  name    = var.react_settings.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.react.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
