data "aws_caller_identity" "current" {}

locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "${local.prefix}-alb-logs-${data.aws_caller_identity.current.account_id}"

  force_destroy = true

  tags = {
    Name = "${local.prefix}-alb-log-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "alb_log" {
  depends_on = [aws_s3_bucket_ownership_controls.alb_log]
  bucket     = aws_s3_bucket.alb_log.id
  acl        = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSALBGetBucketAcl",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.alb_log.arn
      },
      {
        Sid    = "AWSALBLoggingPermissions",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.alb_log.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
