variable "project_settings" {
  description = "プロジェクト共通の設定"
  type = object({
    project     = string
    environment = string
  })
}

variable "domain_name" {
  description = "Route53のホストゾーン名"
  type        = string
}
