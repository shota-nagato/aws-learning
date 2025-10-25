variable "project_settings" {
  type = object({
    project     = string
    environment = string
  })
}

variable "cicd_settings" {
  type = object({
    github_repository = string
    branch_name       = string
    bucket_arn        = string
  })
}
