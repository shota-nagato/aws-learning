resource "aws_s3_bucket" "static_bucket" {
  bucket_prefix = "${local.app_name}-addition-webapp-static-"
}

resource "aws_s3_bucket_public_access_block" "static_bucket_block" {
  bucket = aws_s3_bucket.static_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cf_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.static_bucket.id
  policy     = data.aws_iam_policy_document.s3_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.static_bucket_block]
}

module "static_files" {
  source = "hashicorp/dir/template"

  version = "1.0.2"

  base_dir = "${path.module}/static"
}

resource "aws_s3_object" "static_files" {
  for_each = module.static_files.files

  bucket       = aws_s3_bucket.static_bucket.bucket
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  source_hash = each.value.digests.base64sha256
}
