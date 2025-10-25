output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "bucket_name" {
  value = module.s3.bucket_name
}
