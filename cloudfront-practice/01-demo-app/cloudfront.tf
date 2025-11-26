resource "aws_cloudfront_response_headers_policy" "static_response_headers" {
  name = "${local.app_name}-response-headers"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = false
      value    = "max-age=120"
    }
    # items {
    #   header   = "x-dummy"
    #   override = true
    #   value    = "just because I need to specify one here"
    # }
  }
}

resource "aws_cloudfront_cache_policy" "static_cache_policy" {
  name        = "${local.app_name}-caching"
  default_ttl = 60
  max_ttl     = 31536000
  min_ttl     = 0

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

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.app_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    # S3バケットのリージョナルドメイン名 example: my-bucket.s3.ap-northeast-1.amazonaws.com
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    # OAC
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    # オリジンの一意の識別子
    origin_id = "static"
  }

  # エンドユーザーからのリクエストを受け付けるかどうか
  enabled         = true
  is_ipv6_enabled = true
  # http version default: http2
  http_version        = "http2and3"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "static"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = aws_cloudfront_cache_policy.static_cache_policy.id
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.static_response_headers.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  comment = local.app_name

  tags = {
    Name = local.app_name
  }
}
