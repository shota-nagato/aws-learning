# Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.app_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "oac_lambda" {
  name                              = "${local.app_name}-oac-lambda"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "static_default_policy" {
  name        = "${local.app_name}-static-default-policy"
  min_ttl     = 0
  default_ttl = 3600
  max_ttl     = 3600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "dynamic_policy" {
  name        = "${local.app_name}-dynamic-policy"
  min_ttl     = 0
  default_ttl = 86400
  max_ttl     = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["num1", "num2"]
      }
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_cache_policy" "static_weekly_policy" {
  name        = "${local.app_name}-static-weekly-policy"
  min_ttl     = 0
  default_ttl = 604800
  max_ttl     = 604800

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_origin_request_policy" "all_headers_policy" {
  name = "all-headers-policy"

  headers_config {
    header_behavior = "allExcept"
    headers {
      items = [
        "Host"
      ]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_response_headers_policy" "hourly_policy" {
  name = "${local.app_name}-hourly-headers-policy"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "max-age=3600"
      override = false
    }
  }

  security_headers_config {
    strict_transport_security {
      # HSTS: use only HTTPS
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
  }

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 100
  }
}

resource "aws_cloudfront_response_headers_policy" "daily_policy" {
  name = "${local.app_name}-daily-headers-policy"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "max-age=86400"
      override = true
    }
  }

  security_headers_config {
    strict_transport_security {
      # HSTS: use only HTTPS
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
  }

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 100
  }
}

resource "aws_cloudfront_response_headers_policy" "weekly_policy" {
  name = "${local.app_name}-weekly-headers-policy"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "max-age=604800"
      override = true
    }
  }

  security_headers_config {

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Strict-Transport-Security
    strict_transport_security {
      # HSTS: use only HTTPS
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-Content-Type-Options
    content_type_options {
      override = true
    }

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-Frame-Options
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Referrer-Policy
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-XSS-Protection
    # xss_protection {}
    # Not configured, it's deprecated and a potential security risk according to MDN

    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy
    # content_security_policy {}
    # Not configured as we won't be serving/referencing content from other origins.

  }


  server_timing_headers_config {
    enabled       = true
    sampling_rate = 100
  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  default_root_object = "index.html"

  # Static Origin (S3)
  origin {
    domain_name              = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_id                = "static"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Dynamic Origin (Lambda)
  origin {
    domain_name              = regex("(?:(?P<pr>[^:/?#]+):)?(?://(?P<d>[^/?#]*))?(?P<p>[^?#]*)(?:\\?(?P<q>[^#]*))?(?:#(?P<f>.*))?", aws_lambda_function_url.lambda_url.function_url).d
    origin_id                = "dynamic"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_lambda.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default Behavior (static)
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "static"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.static_default_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hourly_policy.id

    compress = true
  }

  ordered_cache_behavior {
    path_pattern               = "/result/sum"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "dynamic"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.dynamic_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.all_headers_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.daily_policy.id

    compress = true
  }

  ordered_cache_behavior {
    path_pattern               = "/static/*"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "static"
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.static_weekly_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.weekly_policy.id

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  comment = local.app_name

  tags = {
    Name = local.app_name
  }

  custom_error_response {
    error_caching_min_ttl = 60 * 60 * 24 * 7
    error_code            = 400

    response_page_path = "/static/errors/400.html"
    response_code      = 400
  }

  custom_error_response {
    # A 403 by S3 means that the object doesn't exist OR we can't read it.
    error_caching_min_ttl = 60 * 60
    error_code            = 403

    response_page_path = "/static/errors/404.html"
    response_code      = 404
  }

  custom_error_response {
    # This might exist after a fresh deployment
    error_caching_min_ttl = 60 * 60
    error_code            = 404

    response_page_path = "/static/errors/404.html"
    response_code      = 404
  }
}
