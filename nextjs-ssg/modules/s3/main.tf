resource "aws_s3_bucket" "next" {
  bucket = "${var.project_settings.project}-${var.project_settings.environment}-nextjs-bucket"

  tags = {
    Name = "${var.project_settings.project}-${var.project_settings.environment}-nextjs-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "next" {
  bucket = aws_s3_bucket.next.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.next.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "next" {
  bucket = aws_s3_bucket.next.id
  policy = data.aws_iam_policy_document.s3_access.json
}

