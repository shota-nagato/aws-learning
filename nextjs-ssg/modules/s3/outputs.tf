output "bucket_name" {
  value = aws_s3_bucket.next.bucket
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.next.bucket_regional_domain_name
}

output "bucket_origin_id" {
  value = aws_s3_bucket.next.id
}
