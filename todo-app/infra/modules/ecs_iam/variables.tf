variable "project_settings" {
  description = "プロジェクト共通の設定"
  type = object({
    project     = string
    environment = string
  })
}

variable "ecs_iam_settings" {
  type = object({
    ssm_prefix  = string # 例 "/taskfolio/dev"
    cognito_arn = string
  })
}
