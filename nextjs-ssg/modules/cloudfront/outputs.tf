output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.next.id
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.next.arn
}
