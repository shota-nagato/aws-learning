output "COGNITO_USER_POOL_ID" {
  description = "CognitoユーザープールID。アプリ側で使用します。"
  value       = module.cognito.user_pool_id
}

output "COGNITO_CLIENT_ID" {
  description = "CognitoユーザープールのクライアントID。アプリ側で使用します。"
  value       = module.cognito.client_id
}

output "REACT_BUCKET" {
  value = module.react_hosting.s3_bucket_name
}

output "CLOUDFRONT_DISTRIBUTION_ID" {
  value = module.react_hosting.cloudfront_distribution_id
}
