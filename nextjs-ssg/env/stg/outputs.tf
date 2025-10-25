output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "github_actions_role_arn" {
  value = module.cicd_iam.github_actions_role_arn
}
