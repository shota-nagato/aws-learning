variable "project_settings" {
  type = object({
    project     = string
    environment = string
  })
}

variable "cloudfront_distribution_arn" {
  type = string
}
